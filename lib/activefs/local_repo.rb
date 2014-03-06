require 'fileutils'
require 'activefs/repo'
require 'uuid'
require 'pathname'

module Activefs
  class LocalRepo
    #this creates a repo
    #TODO: bare or not to bare (we don't care)
    def self.create(base_path, uuid=nil)
      ['tmp', 'objs', PATH_HEADS, 'refs/remotes'].each do |dir|
        FileUtils.mkdir_p(base_path.join(dir))
      end
      File.open(base_path.join('HEAD'), "w") do |fd|
        fd.write("@default")
      end
      File.open(base_path.join(PATH_HEADS, 'default'), 'w') do |fd|
        fd.write Activefs::Repo::EMPTY_COMMIT
      end

      File.open(base_path.join(PATH_INDEX), 'w') do |fd|
        #fd.write Activefs::Repo::EMPTY_COMMIT
      end


      uuid||=UUID.generate
      File.open(base_path.join(PATH_ID), 'w') do |fd|
        fd.write uuid
      end

      File.open(base_path.join(PATH_VERSION), 'w') do |fd|
        fd.write REPO_VERSION.to_s
      end

      new(base_path)
    end


    # create

    def self.open(base_path)
      repo=new(base_path)
      repo.open
      repo
    end

    attr_reader :base_path, :index

    def initialize(base_path)
      @base_path=Pathname(File.expand_path(base_path))
      @index=nil
      raise "Empty path" unless base_path || base_path.empty?
      @open=false
    end

    def heads
      _heads={}
      Dir.glob("#{@base_path.join(PATH_HEADS)}/*").each do |path_name|
        hash=Util::Objecthash.new(File.read(path_name))
        name=File.basename(path_name)
        _heads[name]=hash
      end
      _heads
    end

    def head(name)
      heads[name.to_s]
    end

    def open?
      @open
    end

    def close
      current_trasaction.reset
      index.close
      snapshots.close
      packfiles.reset
      @open=false
    end

    def open
      check_version
      @index=Index.open(@base_path.join(PATH_INDEX))
      #TODO: repair index if broken
      #@snapshots=Snapshot.open(@base_path.join(PATH_SNAPSHOTS))
      #metadata.open
      #vars.open
      #packfiles.reset
      #remote_peers.connect
      @open=true
      self
    end

    def lock
      assert(open?)
      raise "Can't lock" unless lock
    end

    def set_remote(repo)
      lock(remote_lock)
      assert(@remote_repo.nil?)
      @remote_repo=repo
      @cache_remote_objects=true
    end

    def clear_remote
      lock(remote_lock)
      @remote_repo=nil
    end

    def set_remote_flags(cache)
      lock(remote_lock)
      @cache_remote_objects=cache
    end

    #def has_remote?
    #  lock(remote_lock)
    #  !@remote_repo.nil?
    #end

    #def object(objecthash)
    #  #TODO transaction
    #  index_entry=index.at(objecthash)
    #  packfile=packfiles.for_index_entry(index_entry.packfile)
    #  LocalObject.new(packfile, index_entry)
    #end

    #@param Util::Objecthash hash
    #return the object of an index entry (Tree, Commit, Largeblob, content)
    def get(hash)
      idx_entry=index.at(hash)
      get_object(idx_entry)
    end

    #returns a Tree/Blob/Largeblob/Commit object
    def get_object(idx_entry)
      return nil if idx_entry.objectinfo.empty?
      content=packfile(idx_entry).get(idx_entry)
      case
        when idx_entry.objectinfo.blob?
          Activefs::Blob.from_binary(content)
        when idx_entry.objectinfo.tree?
          Activefs::Tree.from_binary(content)
        when idx_entry.objectinfo.commit?
          Activefs::Commit.from_binary(content)
        when idx_entry.objectinfo.largeblob?
          Activefs::Largeblob.from_binary(content)
        else
          raise "unsupported"
      end
    end

    #@return Array of Activefs::IndexEntry
    def each(path='', recursive=false, head_name='default', &block)
      tree=root(head_name)

      #get down to the given path
      path.split('/').each do |name|
        tree=get(tree[name].hash)
        raise "Not tree #{path}:#{name}" unless tree.tree?
      end


      each_entry(path, tree, recursive, [], &block)
    end

    def root(head_name='default')
      commit_hash=head(head_name)
      commit=get(commit_hash)
      get(commit.tree_hash)
    end


    private

    def packfile(entry)
      Packfile.new(@base_path.join(PATH_OBJS, "pack#{entry.packfile}.pak"), entry.packfile)
    end

    def check_version
      raise "wrong version" unless File.read(base_path.join(PATH_VERSION)) == REPO_VERSION
    end

    def each_entry(path, tree, recursive, entries, &block)
      tree.entries.each do |entry|
        abs_path=(path.empty? ? entry.path : File.join(path,entry.path))

        if block_given?
          yield abs_path, entry
        else
          entries << [abs_path,entry]
        end
        if recursive && entry.tree?
          each_entry(abs_path, get(entry.hash), true, entries, &block)
        end
      end
      entries
    end

  end
end