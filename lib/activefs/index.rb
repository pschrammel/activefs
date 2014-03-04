require 'logger'

module Activefs
  class Index
    def initialize(file_name, options={})
      @file_name=file_name
      @entries=nil
      @entries={} #objecthash -> entry
      @fd=nil
      @logger=options[:logger] || Logger.new('/tmp/activefs.log') #TODO where to log to
    end

    def self.open(file_name, options={})
      new(file_name, options).open
    end

    def open
      #check_dirtyness (size mod totalentrysize == 0)

      raise "corrupted index" unless File.size(@file_name).modulo(IndexEntry::SIZE) == 0
      File.open(@file_name, "r") do |fd|
        while !fd.eof?
          entry=IndexEntry.from_binary(fd.read(IndexEntry::SIZE))
          @entries[entry.objectinfo.hash.to_s]=entry
        end
      end
      #TODO: delete temporary index
      @fd=File.open(@file_name, "a")
      self
    end

    def rewrite(_new_filename="#{@file_name}.new", replace=false)
      File.open(_new_filename, "w+") do |fd|
        @entries.each do |hash, entry|
          fd.write(entry.to_binary)
        end
      end
      #TODO mv new to old if replace
    end

    def update(entry)
      if @entries[entry.objectinfo.hash]
        logger.warn("duplicate index entry")
      end
      @entries[entry.objectinfo.hash]=entry
      write_entry(entry)
    end

    def sync
      @fd.sync
    end

    def close
      sync
      @fd.close
    end

    def size
      @entries.size
    end

    def each
      @entries.each do |hash, entry|
        yield entry
      end
    end

    #@param Util::Objecthash hash can also be a string of a hash
    #@return IndexEntry
    def at(hash)
      @entries[hash.to_s]
    end

    def check(hash)
      !!at(hash)
    end

    def info(hash)
      entry=@entries[hash]
      entry ? entry.objectinfo : nil
    end


    private
    attr_reader :entries, :logger

    def write_entry(entry)
      @fd.write(entry.to_binary)
    end
  end
end