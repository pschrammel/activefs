require 'fastlz'
require "activefs/version"
require 'activefs/local_repo'
require 'activefs/objectinfo'
require 'activefs/index_entry'
require 'activefs/freelist'
require 'activefs/index'
require 'activefs/snapshots'
require 'activefs/metadata'
require 'activefs/packfile'

module Activefs
  REPO_VERSION=1
  PATH_VERSION="version"
  PATH_ID='id'
  PATH_INDEX='index'
  PATH_SNAPSHOTS='snapshots'
end
