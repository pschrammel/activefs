require 'fastlz'
require 'fileutils'

require 'activefs/util/type_test'

require "activefs/version"
require 'activefs/local_repo'
require 'activefs/objectinfo'
require 'activefs/index_entry'
require 'activefs/freelist'
require 'activefs/index'
require 'activefs/snapshots'
require 'activefs/metadata'
require 'activefs/packfile'
require 'activefs/null_zipper'
require 'activefs/rkchunker'

require 'activefs/tree'
require 'activefs/commit'
require 'activefs/largeblob'
require 'activefs/blob'

require 'activefs/cmd/base'
require 'activefs/cmd/checkout'

module Activefs
  REPO_VERSION="ORI1.1"
  PATH_VERSION="version"
  PATH_ID='id'
  PATH_INDEX='index'
  PATH_SNAPSHOTS='snapshots'
  PATH_HEADS='refs/heads'
  PATH_OBJS='objs'
end
