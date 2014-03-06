module Activefs
  class TreeDiff
    class TreeDiffEntry
      attr_reader :type, :path, :index_entry

      def initialize(type, path, index_entry)
        @type=type
        @path=path
        @index_entry=index_entry
      end

      def to_s
        "#{type_to_s} #{path}"
      end

      private
      def type_to_s
        case @type
          when :deleted
            "D"
          when :added
            "A"
          when :modified
            "M"
        end
      end
    end

    attr_reader :diffs
    def initialize
      @diffs=[]
    end

    def dirty?
      !@diffs.empty?
    end

    def diff_to_dir(repo, dst_path)
      @diffs=[]
      Dir.chdir(dst_path)
      fs_files=Set.new(Dir.glob("**/*"))

      repo.each('', true) do |path, entry|
        abs_path=File.join(dst_path, path)

        if fs_files.include?(path) #file exists in both
          file_diff(abs_path, path, entry)
        else #deleted file in fs
          @diffs << TreeDiffEntry.new(:deleted, path, entry)
        end

        fs_files.delete(path)
      end

      fs_files.each do |path| #these files are not in the repo
        @diffs << TreeDiffEntry.new(:added, path, nil)
      end

      self
    end

    private
    def file_diff(abs_path, path, entry)
      if entry.tree? && !File.directory?(abs_path) #directory turned into file
        @diffs << TreeDiffEntry.new(:deleted, path, entry)
        @diffs << TreeDiffEntry.new(:added, path, nil)
      elsif !entry.tree? && File.directory?(abs_path) #file turned into dir
        @diffs << TreeDiffEntry.new(:deleted, path, entry)
        @diffs << TreeDiffEntry.new(:added, path, nil)
      elsif !File.directory?(abs_path) #TODO  (size changed or fs modified since commit time) and hash changed
        if File.size(abs_path) != entry.size
          @diffs << TreeDiffEntry.new(:modified, path, entry)
        end
      end
    end
  end
end

#cases
#new file or dir
#dir -> file
#file -> dir
#attribute changes
# delete of file or dir
