module Activefs
  class Largeblob
    class LargeblobEntry
      def initialize(offset, hash, size)
        @offset=offset
        @hash=hash
        @size=size
      end

      attr_reader :offset, :hash, :size

      def inspect
        "LGBL ENTRY: #{offset} #{size} #{hash}"
      end
    end

    include Util::TypeTest

    def large_blob?
      true
    end

    def content(repo)
      c=''
      parts.each do  |part|
        c << repo.get(part.hash).content
      end
      c
    end

    def initialize(atts={})
      atts.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    attr_accessor :hash, :parts

    def inspect
      "LARGEBLOB: #{hash}\n#{parts.map { |part| part.inspect }.join("\n")}"
    end

    def self.from_binary(input)
      input=input.b
      ptr=0

      hash=Util::Objecthash.from_binary(input[ptr..ptr+Util::Objecthash::SIZE-1])
      ptr += Util::Objecthash::SIZE

      parts=[]
      parts_size=input[ptr..ptr+7].unpack("Q>").first
      ptr += 8

      offset=0
      1.upto(parts_size) do
        part_hash=Util::Objecthash.from_binary(input[ptr..ptr+Util::Objecthash::SIZE-1])
        ptr += Util::Objecthash::SIZE
        size=input[ptr..ptr+1].unpack("S>").first
        ptr += 2
        parts << LargeblobEntry.new(offset, part_hash, size)
        offset += size

      end
      new(:hash => hash, :parts => parts)
    end
  end
end