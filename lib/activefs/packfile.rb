module Activefs
  class Packfile
    ZIP_MINIMUM_SIZE=512

    def initialize(filename,idx)
      @commited=false
      @idx=idx
      @filename=filename

      @filesize=0
      @objectinfos_size=0
    end

    def start(index)
      Packtransaction.new(self,index)
    end
    def commit(transaction,index)
      raise "not yet"
      transaction.validate!

    end
    def open

    end

    def full?

    end

    def add(objectinfo, content)
      #settinging the zipalgo?

    end

    def get(index_entry)
      #TODO: check entry.packfile_id=self.idx
      content=nil

      File.open(@filename) do |fd|
        fd.seek(index_entry.offset)
        content=fd.read(index_entry.packed_size)
      end
      index_entry.zipper.decompress(content)
    end
  end
end