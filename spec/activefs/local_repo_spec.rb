require 'spec_helper'

describe Activefs::LocalRepo do
  let(:repo_base) { ROOT.join('spec/fixtures/oritest_source.ori') }

  describe "create" do
    it "should create a local repo" do
      path=Pathname.new('/tmp/rspec_static')
      Activefs::LocalRepo.create(path)
      path.rmtree
    end
  end

  describe "open" do
    let(:repo) {
      path=Pathname.new('/tmp/rspec_static')
      Activefs::LocalRepo.create(path)
    }
    it "should open" do
      repo.open
    end
    it "should check the version"
    it "should be opened" do
      repo.open.should be_open
    end
  end

  describe 'head(s)' do
    it "should list em" do
      r=Activefs::LocalRepo.open(repo_base)
      r.heads.should == {"default" => "0467061ef6031576b40418d05b5c407d89d3b751161e215f62f0e87f496ad9b9"}
    end
    it "should get hash of one" do
      r=Activefs::LocalRepo.open(repo_base)
      r.head("default").should == "0467061ef6031576b40418d05b5c407d89d3b751161e215f62f0e87f496ad9b9"
    end
  end
end