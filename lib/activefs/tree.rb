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

      def index_hash
        large_blob? ? large_hash : hash
      end

      def large_blob?
        @type == :lgbl
      end

      def tree?
        @type==:tree
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

      def mtime
        self['Smtime']
      end

      def ctime
        self['Smtime']
      end

      def group
        self['Sgroup']
      end

      def user
        self['Suser']
      end

      def link?
        false #TODO
      end

      def size
        self['Ssize']
      end

      def perms
        self['Sperms']
      end

      def ur?
        perms & 256 != 0
      end

      def uw?
        perms & 128 != 0
      end

      def ux?
        perms & 64 != 0
      end

      def gr?
        perms & 32 != 0
      end

      def gw?
        perms & 16 != 0
      end

      def gx?
        perms & 8 != 0
      end

      def or?
        perms & 4 != 0
      end

      def ow?
        perms & 2 != 0
      end

      def ox?
        perms & 1 != 0
      end
    end #TreeEntry

    def initialize(entries=[])
      @entries=entries.inject({}) do |hash, entry|
        hash[entry.path]=entry; hash
      end
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
          value=case name
                  when 'Ssize'
                    value.unpack('Q').first
                  when 'Slink'
                    value.unpack('C').first
                  when 'Sperms'
                    value.unpack('L<').first #& 16777215
                  when 'Smtime'
                    Time.at(value.unpack('Q').first)
                  when 'Sctime'
                    Time.at(value.unpack('Q').first)
                  else
                    value
                end
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