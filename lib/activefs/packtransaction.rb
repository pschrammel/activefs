module Activefs
  class Packtransaction
    MAXSIZE=64*1024*1024
    MAXOBJS=2048

    def initialize(packfile, index)
      @total=0
      @committed=false
      @packfile=packfile
      @index=index
      @objectinfos={}
    end

    attr_reader :total

    def full?
      @total >= MAXSIZE || @objectinfos.size > MAXOBJS
    end

    def add(objectinfo, content)
      raise "not yet"
      #TODO: check if objectinfos already has this hash?
      objectinfo.zipalgo=Objectinfo::ZIP_ALGO_LZMA
      @total += content.size
    end

    def has?
      raise "not yet"
    end

    def commited?
      @commited
    end

    def validate!
      #objectinfo.size==contents.size
    end

    def commit
      raise "already commited" if commited?
      @packfile.commit(self, @index)
      @commited=true
    end
  end
end