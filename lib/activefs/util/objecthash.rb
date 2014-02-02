module Activefs
  module Util

    class Objecthash
      SIZE=32 #=bytes the string size = *2
      STR_SIZE=SIZE*2
      EMPTY="\x00"*SIZE

      def self.from_binary(str)
        hash=new
        hash.value=str
        hash
      end

      def initialize(hex_str=nil)
        raise "too short hash" unless hex_str.nil? || hex_str.length == STR_SIZE
        #hex_str.scan(/../).map { |x| x.hex }.pack('c*')
        @value=hex_str ? hex_str.scan(/../).map { |x| x.hex.chr }.join : EMPTY

      end

      def empty?
        @value==EMPTY
      end

      def to_s
        @value.unpack('H*').first
        #@value.each_byte.map { |b| b.to_s(16) }.join this doesn't work
      end

      def to_binary
        @value
      end

      def value=(binaryhash)
        @value=binaryhash
      end

      def ==(obj)
        obj.value==@value
      end

      protected
      def value
        @value
      end
    end
  end
end