module Activefs
  class Metadata

    def initialize(options={})
      @filename=options[:filename]
    end

    def open
      metaentries={} #hash => count
      File.open(@filename) do |fd|
        num=fd.read(4)
        entries=num.unpack("L").first

        num_rc=fd.read(4).unpack("L>").first
        num_md=fd.read(4).unpack("L>").first

        puts entries
        puts num_rc
        puts num_md
        read=3*4

        1.upto(num_rc) do
          hash=Util::Objecthash.from_binary(fd.read(Util::Objecthash::SIZE))
          refcount=fd.read(4).unpack("L>").first
          metaentries[hash.hash]=refcount
          puts "#{hash.to_s} -> #{refcount}"
          read += (4 + Util::Objecthash::SIZE)
        end
        #puts metaentries.size
        #puts read

        1.upto(num_md) do
          hash=Util::Objecthash.from_binary(fd.read(Util::Objecthash::SIZE))
          num_mde=fd.read(4).unpack("L>").first
          puts "#{hash}: #{num_mde}"
          read += (4+Util::Objecthash::SIZE)
          1.upto(num_mde) do
            att=read_pstr(fd)
            value=read_pstr(fd)
            read += (att.size+1+value.size+1)
            puts "  #{att} -> #{value}"
          end
        end
        puts read
      end
    end

    def read_pstr(fd)
      #p fd.read(1) #read the pstr header should == A8
      len=fd.read(1).unpack('C').first
      fd.read(len)
    end
    def self.from_binary(str)

    end
  end
end