module Activefs
  class Freelist
    def self.filename(repo)
      repo.base_path.join("objs", ".freelist")

    end

    def initialize(repo)
      @repo=repo
      @sizes=[]
    end

    attr_reader :sizes

    def read
      str=File.read(self.class.filename(@repo)).force_encoding('ASCII-8BIT')
      sizes=str.unpack("L>*")
      size=sizes.shift
      raise ".freelist broken #{sizes} #{size}" unless sizes.size==size
      @sizes=sizes
    end

    def recompute
    end

    def write

    end
  end
end
