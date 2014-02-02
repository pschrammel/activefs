require 'spec_helper'

describe Activefs::Objectinfo do
  let(:hash) {
    Activefs::Util::Objecthash.new("1234567890"*6+"abcd")
  }
  it "should set defaults" do
    info=Activefs::Objectinfo.new
    info.hash.should be_nil
    info.payload_size.should == -1
    info.flags.should == Activefs::Objectinfo::FLAG_DEFAULT
    info.type.should == Activefs::Objectinfo::TYPE_NULL

    info=Activefs::Objectinfo.new(hash, Activefs::Objectinfo::TYPE_TREE, Activefs::Objectinfo::FLAG_FASTLZ, 8000)
    info.hash.should == hash
    info.type.should == Activefs::Objectinfo::TYPE_TREE
    info.flags.should == Activefs::Objectinfo::FLAG_FASTLZ
    info.payload_size.should == 8000
  end

  it "should produce binary format" do
    info=Activefs::Objectinfo.new(hash, Activefs::Objectinfo::TYPE_TREE, Activefs::Objectinfo::FLAG_FASTLZ, 8000)
    binary=info.to_binary
    binary[0..3].should == "TREE"
    binary[4..4+31].should == hash.to_binary
    binary[36..39].should == [Activefs::Objectinfo::FLAG_FASTLZ].pack("L")
    binary[40..43].should == [8000].pack("L")
    info.to_binary.encoding.to_s.should == 'ASCII-8BIT'
  end
  it "should parse binary" do
    str=Activefs::Objectinfo.new(hash, Activefs::Objectinfo::TYPE_TREE, Activefs::Objectinfo::FLAG_FASTLZ, 8000).to_binary
    info=Activefs::Objectinfo.from_binary(str)
    info.hash.should == hash
    info.type.should == Activefs::Objectinfo::TYPE_TREE
    info.flags.should == Activefs::Objectinfo::FLAG_FASTLZ
    info.payload_size.should == 8000
  end
end
