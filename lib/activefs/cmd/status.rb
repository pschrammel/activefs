module Activefs
  module Cmd
    class Status < Base

      def run(repo, dst_path)
        diff=Activefs::TreeDiff.new
        diff.diff_to_dir(repo,dst_path)
        if diff.dirty?
          puts "Dirty:"
          puts diff.diffs
        end
      end



    end
  end
end
