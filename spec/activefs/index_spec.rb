require 'spec_helper'

describe Activefs::Index do
  let(:fixture_index_name) { ROOT.join('spec/fixtures/oritest_source.ori/index') }
  it "should open one" do
    index=Activefs::Index.new(fixture_index_name).open
    index.size.should == 1428
    index.close
  end

  it "should rewrite" do
    index=Activefs::Index.new(fixture_index_name).open
    index.rewrite
    index.close
  end

  it "should find an entry by hash" do
    index=Activefs::Index.new(fixture_index_name).open
    a_key=index.send(:entries).keys.first
    entry=index.at(a_key)
    entry.should_not be_nil
    entry.objectinfo.hash.to_s.should == a_key
  end

  it "should return the objectinfo" do
    index=Activefs::Index.new(fixture_index_name).open
    a_key=index.send(:entries).keys.first
    info=index.info(a_key)
    info.should_not be_nil
    info.hash.to_s.should == a_key
  end
end