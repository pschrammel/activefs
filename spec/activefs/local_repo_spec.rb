require 'spec_helper'

describe Activefs::LocalRepo do
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
end