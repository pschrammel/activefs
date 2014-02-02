require 'activefs/util/objecthash'
module Activefs
  class Objectinfo
    TYPE_NULL=0
    TYPE_COMMIT=1
    TYPE_TREE=2
    TYPE_BLOB=3
    TYPE_LARGE_BLOB=4
    TYPE_PURGED=5
    TYPE__SIZE=4 #size of the type string

    FLAG_UNCOMPRESSED=0
    FLAG_FASTLZ=1
    FLAG_LZMA=2
    FLAG_ZIPMASK=15
    FLAG_DEFAULT=0

    ZIP_ALGO_UNKNOWN=0
    ZIP_ALGO_NONE=1
    ZIP_ALGO_FASTLZ=2
    ZIP_ALGO_LZMA=3
    ZIP_ALGO_DEFAULT= ZIP_ALGO_UNKNOWN

    SIZE=TYPE__SIZE+Util::Objecthash::SIZE+4+4 # (flag and payloadsize as uint32)
                 #@param Objecthash hash
    def initialize(hash=nil, type=TYPE_NULL, flags=FLAG_DEFAULT, payload_size=-1, zipalgo=ZIP_ALGO_DEFAULT)
      @type=type
      @flags=flags
      @zipalgo=zipalgo
      @payload_size=payload_size
      @hash=hash
    end

    attr_reader :type, :flags, :payload_size, :hash, :zipalgo

    def self.from_binary(str)
      new(Util::Objecthash.from_binary(str.byteslice(TYPE__SIZE.. TYPE__SIZE+Util::Objecthash::SIZE-1)),
          str_to_type(str.byteslice(0..TYPE__SIZE-1)),
          str.byteslice(TYPE__SIZE+Util::Objecthash::SIZE..TYPE__SIZE+Util::Objecthash::SIZE+3).unpack("L>").first,
          str.byteslice(TYPE__SIZE+Util::Objecthash::SIZE+4..TYPE__SIZE+Util::Objecthash::SIZE+3+4).unpack("L>").first
      )
    end

    def to_s
      "#{type_to_str} #{@hash} #{flags_to_s(@flags)} PAYLOAD_SIZE: #{payload_size}"
    end

    def to_binary
      "#{type_to_str}#{@hash.to_binary}"+[@flags, @payload_size].pack("L>L>")
    end

    def ==(object)
      object.type == type &&
          object.flags==flags &&
          object.payload_size == payload_size &&
          object.hash == hash
    end

    #zipper hast to support compress/uncompress
    def zipper
      case flags & FLAG_ZIPMASK
        when FLAG_FASTLZ
          FastLZ
        when FLAG_LZMA
          raise "lzma zipper not implemented"
        when FLAG_ZIPMASK
          raise "zip zipp not implemented"
        when FLAG_UNCOMPRESSED
          NullZipper
      end
    end

    private
    def type_to_str
      case @type
        when TYPE_NULL
          "NULL"
        when TYPE_COMMIT
          "CMMT"
        when TYPE_TREE
          "TREE"
        when TYPE_BLOB
          "BLOB"
        when TYPE_LARGE_BLOB
          "LGBL"
        when TYPE_PURGED
          "PURG"
        else
          raise "unknown type"
      end
    end

    def self.str_to_type(str)
      case str
        when "NULL"
          TYPE_NULL
        when "CMMT"
          TYPE_COMMIT
        when "TREE"
          TYPE_TREE
        when "BLOB"
          TYPE_BLOB
        when "LGBL"
          TYPE_LARGE_BLOB
        when "PURG"
          TYPE_PURGED
        else
          raise "unknown type string"
      end
    end

    def flags_to_s(flags)

      case flags & FLAG_ZIPMASK
        when FLAG_FASTLZ
          "F"
        when FLAG_LZMA
          "L"
        when FLAG_ZIPMASK
          "Z"
        when FLAG_UNCOMPRESSED
          "U"
      end
    end
  end
end