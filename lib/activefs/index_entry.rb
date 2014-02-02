require 'digest'
require 'activefs/objectinfo'
module Activefs
  class IndexEntry
    CHK_SIZE=16 #(32 would be correct but lets keep to ori's wrong implementation)
    SIZE = Activefs::Objectinfo::SIZE+3*4 + CHK_SIZE # u32 + 32 for the hash

    def initialize(objectinfo, offset, packed_size, packfile)
      @objectinfo=objectinfo
      @offset=offset
      @packed_size=packed_size
      @packfile=packfile
    end

    attr_reader :objectinfo, :offset, :packed_size, :packfile

    def payload_size
      objectinfo.payload_size
    end

    def zipper
      objectinfo.zipper
    end

    def self.from_binary(str)
      index_entry=new(
          Activefs::Objectinfo.from_binary(str.byteslice(0..Activefs::Objectinfo::SIZE-1)),
          str.byteslice(Activefs::Objectinfo::SIZE..Activefs::Objectinfo::SIZE+3).unpack("L>").first, #offset
          str.byteslice(Activefs::Objectinfo::SIZE+4..Activefs::Objectinfo::SIZE+7).unpack("L>").first, #packed_size
          str.byteslice(Activefs::Objectinfo::SIZE+8..Activefs::Objectinfo::SIZE+11).unpack("L>").first #packfile
      )
      unless checksum(str.byteslice(0..Activefs::Objectinfo::SIZE+11)) == str.byteslice(Activefs::Objectinfo::SIZE+12..Activefs::Objectinfo::SIZE+11+CHK_SIZE)
        raise "index checksum corrupt #{checksum(str.byteslice(0..Activefs::Objectinfo::SIZE+11)).inspect} <->  #{str.byteslice(Activefs::Objectinfo::SIZE+12..Activefs::Objectinfo::SIZE+11+CHK_SIZE).inspect}"
      end
      index_entry
    end

    def to_binary
      content=@objectinfo.to_binary+[@offset, @packed_size, @packfile].pack("L>L>L>")
      content+checksum(content)
    end

    def inspect
      "#{objectinfo} OFFSET:#{@offset} PACKED_SIZE:#{packed_size} FILE:#{packfile}"
    end

    private

    def checksum(content)
      self.class.checksum(content)
    end

    def self.checksum(content)
      Digest::SHA256.new.digest(content)[0..CHK_SIZE-1]
    end
  end
end