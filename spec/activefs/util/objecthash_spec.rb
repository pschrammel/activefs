require 'spec_helper'

describe Activefs::Util::Objecthash do
  let(:hash) {
    "1234567890"*6+"abcd" #64
  }
  let(:bin) {
    hash.scan(/../).map { |x| x.hex }.pack('c*')
  }
  let(:hash2) {
      "1234567890"*6+"ABCD"
    }

  it "should new" do
    Activefs::Util::Objecthash.new(hash).to_s.should == hash
  end
  it "should be comparable" do
    Activefs::Util::Objecthash.new(hash).should == Activefs::Util::Objecthash.new(hash2)
  end
  it "should return binary" do
    Activefs::Util::Objecthash.new(hash).to_binary.should == bin
  end
  it "should recognize emptyness" do
    Activefs::Util::Objecthash.new("0"*64).should be_empty
    Activefs::Util::Objecthash.new(hash).should_not be_empty
  end
  it "should have the right size" do
    Activefs::Util::Objecthash.new("0"*64).to_binary.bytesize.should ==  Activefs::Util::Objecthash::SIZE
  end
end