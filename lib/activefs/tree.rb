module Activefs
  class Tree
    include Util::TypeTest
    def tree?
      true
    end

    class TreeEntry
      def initialize(type)
        @type=type #:tree,:blob,:lgbl
        @atts={}
      end

      attr_accessor :large_hash, :hash, :path
      attr_reader :lgbl

      def large_blob?
        @type == :lgbl
      end

      def inspect
        "TREE_ENTRY: #{@type} #{@hash} #{@path} #{@atts.inspect}"
      end

      def [](name)
        @atts[name]
      end

      def []=(name, value)
        @atts[name]=value
      end
    end #TreeEntry

    def initialize(entries=[])
      @entries=entries.inject({}) do |hash,entry| hash[entry.path]=entry;  hash end
    end

    def entries
      @entries.values
    end

    def [](name)
      @entries[name]
    end

    def inspect
      @entries.map(&:inspect).join("\n")
    end

    def self.from_binary(input)
      entries=[]
      input=input.b
      ptr=0
      type_size=input.unpack("CQ>")
      ptr += 9
      #check type[0] == A7

      1.upto(type_size[1]) do
        entrytype=input[ptr..ptr+3]
        ptr += 4
        entry=case entrytype
                when 'blob'
                  TreeEntry.new(:blob)
                when 'tree'
                  TreeEntry.new(:tree)
                when 'lgbl'
                  TreeEntry.new(:lgbl)
                else
                  raise "WTF"
              end
        ptr +=1 # AA
        entry.hash=Util::Objecthash.from_binary(input[ptr..ptr+Util::Objecthash::SIZE-1])
        ptr += Util::Objecthash::SIZE
        if entry.large_blob?
          entry.large_hash=Util::Objecthash.from_binary(input[ptr..ptr+Util::Objecthash::SIZE-1])
          ptr += 1 # AA
          ptr +=Util::Objecthash::SIZE
        end
        path=read_pstr(input[ptr..-1])
        ptr += path.size + 3
        entry.path=path.force_encoding("UTF-8")

        _type, size=input[ptr..ptr+5].unpack("CL>") #type should be A6
        ptr+=5
        atts={}
        1.upto(size) do
          name=read_pstr(input[ptr..-1])
          ptr += name.size + 3
          value=read_pstr(input[ptr..-1])
          ptr += value.size + 3
          entry[name]=value
        end
        entries << entry

      end
      new(entries)
    end

    def self.read_pstr(input)
      #p fd.read(1) #read the pstr header should == A8
      _prefix=input.unpack("CCC") #this should be a8, a4, len

      input[3..3+_prefix[2]-1]

    end
  end
end