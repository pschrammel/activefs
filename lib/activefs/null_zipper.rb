module Activefs
  class NullZipper
    def self.decompress(content)
      content
    end

    def self.compress(content)
      content
    end
  end
end