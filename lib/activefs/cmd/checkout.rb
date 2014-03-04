module Activefs
  module Cmd
    class Checkout < Base

      def run(repo, dst_path)

        repo.each('', true) do |path, tree_entry|
          dst_filename=File.join(dst_path, path, tree_entry.path)
          #TODO: if the destination already exists delete it
          #TODO: cleanup other files/dirs if untouched
          #next if entry.purged?
          obj=repo.get(tree_entry.hash)

          case
            when obj.tree?
              FileUtils.mkdir(dst_filename) unless File.exist?(dst_filename)#TODO: chmod
            when obj.blob?
              write(dst_filename, obj.to_s)
            when obj.large_blob?
              write(dst_filename, obj.content(repo))
            else
              raise "unsupported"
          end

        end

      end #run

      private
      def write(path, content)
        File.open(path, "w") do |fd|
          fd.write(content)
        end
      end

    end
  end
end