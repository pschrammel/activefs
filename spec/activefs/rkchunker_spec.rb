require 'spec_helper'
require 'ruby-prof'

describe Activefs::Rkchunker do
  it "should init" do
    File.open(ROOT.join('spec/fixtures/file11.tst')) do |fd|
      result = RubyProf.profile do
        r=Activefs::Rkchunker.new
        r.chunk(fd) do |event, off, hash, content|
          puts "break: #{event} #{off} #{hash}"
        end
      end
      printer = RubyProf::GraphPrinter.new(result)
      printer.print(STDOUT, {})
    end
  end
end
