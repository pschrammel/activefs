require 'activefs/util/objecthash'
module Activefs
  class Repo
    EMPTY_COMMIT = Activefs::Util::Objecthash.new("0000000000000000000000000000000000000000000000000000000000000000")
    EMPTYFILE_HASH= Activefs::Util::Objecthash.new("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
  end
end