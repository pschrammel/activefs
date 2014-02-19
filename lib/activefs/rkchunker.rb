module Activefs
  class Rkchunker
    def initialize
      @hashlen=32
      @b=31
      @bit64=2**64-1
      @target=4096
      @min=2048
      @max=8192

      #@token=1
      #1.upto(@hashlen) do |multi|
      #  @token = (@token * @b) & @bit64
      #end

      @token = 3671467063254694913

      @lut=[]
      0.upto(255) do |idx|
        @lut[idx] = idx #(idx * token) & @bit64
      end
    end

    #@param IO io
    #@param block will be called with the chunk
    def chunk(io)

      hash=0
      off=0
      phase = 1 #there are two phases 1. hashing the first min bytes
                     #                     2. finding the best chunk or max bytes

      the_chunk=io.read(@hashlen)
      return unless the_chunk
      yield off, 0, the_chunk && return if the_chunk.size < @hashlen

      #the first @hashlen bytes init the hash
      while off < @hashlen do
        hash = (((hash * @b) & @bit64)+ the_chunk.getbyte(off)) & @bit64
        off += 1
      end

      chunk_off=off
      window=the_chunk.bytes #a sliding window of the last @hashlen bytes

      #go the next bytes go from byte 32 -
      io.each_byte do |byte| #integer!
        the_chunk << byte
        window << byte
        window_byte=window.shift
        #original:
        #hash= ((((hash-@lut[the_chunk.getbyte(chunk_off-@hashlen)]) & @bit64) * @b) + byte) & @bit64
        hash= ((((hash-window_byte) & @bit64) * @b) + byte) & @bit64
        puts "#{off} #{chunk_off} #{hash} #{window_byte} #{byte} #{phase} #{hash % @target}"

        case
          when io.eof? # fire chunk if eof
            yield :eof, off, hash, the_chunk
          when phase == 1 && (chunk_off == @min)
            phase = 2
          when phase == 2 && (hash % @target == 1)
            yield :chunked, off, hash, the_chunk
            phase = 1
            chunk_off = -1
            the_chunk=''
            hash= ((((hash-window_byte) & @bit64) * @b) + byte) & @bit64
          when phase == 2 && (chunk_off == @max)
            yield :max, off, hash, the_chunk
            phase = 1
            chunk_off = -1
            the_chunk=''
        end


        off += 1
        chunk_off += 1

      end
    end #chunk

  end
end