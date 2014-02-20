module Activefs
  class Commit
    include Util::TypeTest

    def commit?
      true
    end

    def initialize(atts={})
      atts.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    attr_accessor :tree_hash, :snapshot_name, :version, :user, :message, :signature, :graft_repo,
                  :graft_path, :graft_commit_id, :date, :parent1_hash, :parent2_hash

    def inspect
      "COMMIT: V#{version}:#{tree_hash} #{date} S:#{snapshot_name} U:#{user} '#{message}' #{signature} G:#{graft_repo} #{graft_path} #{graft_commit_id} P1:#{parent1_hash} P2:#{parent2_hash}"
    end

    def self.from_binary(input)
      input=input.b
      ptr=0
      type_version=input.unpack("CL>")
      version=type_version[1]
      ptr += 5
      type_flags=input[ptr..ptr+4].unpack("CL>")
      flags=type_flags[1]
      ptr += 5

      ptr +=1 # AA
      tree_hash=Util::Objecthash.from_binary(input[ptr..ptr+Util::Objecthash::SIZE-1])
      ptr += Util::Objecthash::SIZE

      type_parents=input[ptr..ptr+1].unpack("CC")
      parents_size=type_parents[1]
      ptr += 2

      case parents_size
        when 0

        when 1
          parent1_hash=Util::Objecthash.from_binary(input[ptr..ptr+Util::Objecthash::SIZE-1])
          ptr += Util::Objecthash::SIZE

        when 2
          parent1_hash=Util::Objecthash.from_binary(input[ptr..ptr+Util::Objecthash::SIZE-1])
          ptr += Util::Objecthash::SIZE
          parent2_hash=Util::Objecthash.from_binary(input[ptr..ptr+Util::Objecthash::SIZE-1])
          ptr += Util::Objecthash::SIZE
        else
          raise "#{parents_size} parents!"
      end

      user=read_pstr(input[ptr...-1])
      ptr += user.size+3

      type_date=input[ptr..ptr+8].unpack("CQ>")
      date=type_date[1]
      ptr += 9

      snapshot_name=read_pstr(input[ptr...-1])
      ptr +=snapshot_name.size+3

      graft_repo=nil
      graft_path=nil
      graft_commit_id=nil


      if flags & 1 == 1 #is graft
        graft_repo=read_pstr(input[ptr...-1])
        ptr +=graft_repo.size+3
        graft_path=read_pstr(input[ptr...-1])
        ptr +=graft_path.size+3
        graft_commit_id=read_pstr(input[ptr...-1])
        ptr +=graft_commit_id.size+3
                        #TODO: check !graft_path.empty? && !graft_commit_id.empty?
      end

      if flags & 2 == 2 #has signature
        signature=read_pstr(input[ptr...-1])
        ptr +=signature.size+3
      end

      message=read_pstr(input[ptr...-1])
      ptr +=message.size+3

      new(:tree_hash => tree_hash,
          :snapshot_name => snapshot_name,
          :version => version,
          :user => user,
          :message => message,
          :signature => signature,
          :graft_repo => graft_repo,
          :graft_path => graft_path,
          :graft_commit_id => graft_commit_id,
          :date => date,
          :parent1_hash => parent1_hash,
          :parent2_hash => parent2_hash
      )
    end

    def self.read_pstr(input)
      #p fd.read(1) #read the pstr header should == A8
      _prefix=input.unpack("CCC") #this should be a8, a4, len

      input[3..3+_prefix[2]-1]

    end
  end
end