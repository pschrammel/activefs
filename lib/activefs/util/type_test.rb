module Activefs
  module Util
    module TypeTest
      def tree?
        false
      end

      def blob?
        false
      end

      def commit?
        false
      end

      def large_blob?
        false
      end

      def blobish?
        large_blob? || blob?
      end

    end
  end
end