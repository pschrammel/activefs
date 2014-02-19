require 'spec_helper'

describe Activefs::Packfile do
  let(:fixture_index_name) { ROOT.join('spec/fixtures/oritest_source.ori/index') }
  let(:packfile_name) { ROOT.join('spec/fixtures/oritest_source.ori/objs/pack0.pak') }
  let(:index) { Activefs::Index.new(fixture_index_name).open }
  let(:tree_hash) { "aca9e87acc0602718b46f7b4dd5edc6b6d678d8f3246a252b5017cb794e9d92f" }
  let(:hash_content) { "Foo\n" }
  it "should get an entry" do
    #  th="87503af3c33f4cb2b37c61a5bbb48a7a10340fc873ba51628d1086aa267f579b" #BLOB
    #th="d9014c4624844aa5bac314773d6b689ad467fa4e1d1a50a1b8a99d5a95f72ff5" #Hello World unpacked
    th="3eae1599bb7f187b86d6427942d172ba8dd7ee5962aab03e0839ad9d59c37eb0" #"Foo\n" unpacked

    #th="0467061ef6031576b40418d05b5c407d89d3b751161e215f62f0e87f496ad9b9" #CMMT unpacked
    #th="5a09124cb7c41edb50e8d8e5814528f1cdef8b09aced39063da72262cc63f849" #TREE   unpacked
    entry=index.at(th)

    #p entry
    packfile0=Activefs::Packfile.new(packfile_name, 0)
    content=packfile0.get(entry)
    content.size.should == entry.payload_size
    content.should== hash_content
  end

  it "should unpack a tree" do
    th="775452d0bd8e2e8fdeb7a2ef94084eb8f7e5abdf0a98dcb3b24a550854bcec9d" #TREE packed
                                                                          #th="386cdddac6ed30b1de85c1cb1ee7fc04f872281aaf3cd1cbd794d699c6682e09"
    entry=index.at(th)
    packfile0=Activefs::Packfile.new(packfile_name, 0)
    content=packfile0.get(entry)
    tree=Activefs::Tree.from_binary(content)
    tree.entries.size.should == 3

  end

  it "should return a commit" do
    th="0467061ef6031576b40418d05b5c407d89d3b751161e215f62f0e87f496ad9b9"
    entry=index.at(th)
    packfile0=Activefs::Packfile.new(packfile_name, 0)
    content=packfile0.get(entry)
    #p content
    commit=Activefs::Commit.from_binary(content)
    #p commit
  end

  it "should return a largeblob" do
    th="c8746154ffa0369a6292ef342b926ce5481b2a949d305f7660421192d0657319"
    entry=index.at(th)
    packfile0=Activefs::Packfile.new(packfile_name, 0)
    content=packfile0.get(entry)
    p content
    lblob=Activefs::Largeblob.from_binary(content)
    p lblob
  end
end
