require 'spec_helper'

describe Activefs::Freelist do
  let(:repo_name) { ROOT.join('spec/fixtures/oritest_source.ori') }
  it "should open" do
    repo=Activefs::LocalRepo.new(repo_name)
    f= Activefs::Freelist.new(repo)
    f.read.should== [6]
  end
end