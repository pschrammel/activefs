require 'spec_helper'

describe Activefs::IndexEntry do
  it "should do the binary roundtrip" do
    hash=Activefs::Util::Objecthash.new("1234567890"*6+"abcd")
    objectinfo=Activefs::Objectinfo.new(hash, Activefs::Objectinfo::TYPE_TREE, Activefs::Objectinfo::FLAG_FASTLZ, 8000)
    index_entry=Activefs::IndexEntry.new(objectinfo, 3000, 4000, 5000)
    index_entry.to_binary.size.should == Activefs::IndexEntry::SIZE
    index_entry2=Activefs::IndexEntry.from_binary(index_entry.to_binary)
    index_entry2.objectinfo.should == objectinfo
    index_entry2.offset.should == 3000
    index_entry2.packed_size.should == 4000
    index_entry2.packfile.should == 5000
  end
end