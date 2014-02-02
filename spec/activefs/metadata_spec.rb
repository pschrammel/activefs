require 'spec_helper'

describe Activefs::Metadata do
  let(:fixture_metadata_name) { ROOT.join('spec/fixtures/oritest_source.ori/metadata') }
  it "should read data" do
    meta=Activefs::Metadata.new(:filename => fixture_metadata_name)
    meta.open
  end
end