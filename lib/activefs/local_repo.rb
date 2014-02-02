require 'fileutils'
require 'activefs/repo'
require 'uuid'
require 'pathname'

module Activefs
  class LocalRepo
    #this creates a repo
    #TODO: bare or not to bare (we don't care)
    def self.create(base_path, uuid=nil)
      ['tmp', 'objs', 'refs/heads', 'refs/remotes'].each do |dir|
        FileUtils.mkdir_p(base_path.join(dir))
      end
      File.open(base_path.join('HEAD'), "w") do |fd|
        fd.write("@default")
      end
      File.open(base_path.join('refs/heads/default'), 'w') do |fd|
        fd.write Activefs::Repo::EMPTY_COMMIT
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

    attr_reader :base_path
    def initialize(base_path)
      @base_path=Pathname(base_path)
      @index=nil
      raise "Empty path" unless base_path || base_path.empty?
      @open=false
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
      @snapshots=Snapshot.open(@base_path.join(PATH_SNAPSHOTS))
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

    def has_remote?
      lock(remote_lock)
      !@remote_repo.nil?
    end

    def object(objecthash)
      #TODO transaction
      index_entry=index.at(objecthash)
      packfile=packfiles.for_index_entry(index_entry.packfile)
      LocalObject.new(packfile, index_entry)
    end

    private
    attr_reader :index
    def check_version
      raise "wrong version" unless File.read(base_path.join(PATH_VERSION)) == REPO_VERSION.to_s
    end
  end
end