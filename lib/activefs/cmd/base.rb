module Activefs
  module Cmd
    class Base
      def self.run(*args)
        new.run(*args)
      end
    end
  end
end