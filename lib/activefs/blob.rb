module Activefs
  class Blob
    include Util::TypeTest

    def blob?
      true
    end

    def initialize(content)
      @content=content
    end

    def self.from_binary(content)
      new(content)
    end

    attr_reader :content

    def to_s
      @content
    end

    def inspect
      @content.inspect
    end
  end
end