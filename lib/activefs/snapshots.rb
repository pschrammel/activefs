module Activefs
  class Snapshots
    def initialize(file_name, options={})
      @file_name=file_name
      @snapshots={} # name -> hash
      @fd=nil
    end

    def self.open(file_name, options={})
      self.new(file_name, options).open
    end

    def open
      File.open(file_name) do |fd|
        fd.eachline do |line|
          hash=line[0..63] #pos 64 is a space
          name=line[65..-1].strip
          @snapshots[name]=hash
        end
      end
      @fd=File.open(file_name, 'a')
      self
    end

    def sync
      @fd.sync
    end

    def close
      sync
      @fd.close
    end

    def rewrite(_new_filename="#{@file_name}.new", replace=false)
      File.open(_new_filename, "w+") do |fd|
        @snapshots.each do |name, hash|
          @fd.puts(snapshot_entry(name, hash))
        end
      end
      #TODO mv new to old if replace

    end

    def add(name, commit_objecthash)
      raise "empty_commit" if commit_objecthash.empty?
      @fd.puts(snapshot_entry(name, commit_objecthash.hash))
      @snapshots[name]=commit_objecthash.hash
    end

    def by_name(name)
      @snapshots[name]
    end

    def each
      @snapshots.each do |name, hash|
        yield name, hash
      end
    end

    private
    def snapshot_entry(name, hash)
      "#{hash} #{name}"
    end
  end
end