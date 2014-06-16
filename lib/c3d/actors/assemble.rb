#!/usr/bin/env ruby

module C3D
  class Assemble
    attr_reader :content

    def initialize contract
      @content = []
      assemble_and_perform_queries contract
    end

    private

      def assemble_and_perform_queries contract
        contract = address_guard contract
        puts "[C3D::#{Time.now.strftime( "%F %T" )}] Assembling >>\t" + contract
        get_the_contract contract
      end

      def get_the_contract contract
        if ab? contract
          get_ab_content contract
        elsif ba? contract
          get_ba_content contract
        end
      end

      def get_ab_content contract
        if can_we_get_the_k? contract
          blob = send_query contract, '0x13'
          get_the_blob blob, contract
        end
      end

      def get_ba_content contract
        if can_we_get_the_k? contract
          group = {}
          group[:prev] = send_query contract, '0x19'
          until group[:prev] == '0x30'
            group = get_the_group contract, group[:prev]
            get_the_blob group[:blob], group[:this] if group[:blob]
          end
        end
      end

      def can_we_get_the_k? contract
        behav = send_query contract, '0x18'
        if behav == ('0x01' || '0x1')
          return true
        end
        return false
      end

      def get_the_group contract, group_id
        this_group = {}
        this_group[:this] = group_id
        if can_we_get_the_group? contract, group_id
          this_group[:blob] = send_query(contract, content_slot(group_id))
          this_group[:prev] = send_query(contract, prev_link_slot(group_id))
        else
          this_group[:prev] = send_query(contract, prev_link_slot(group_id))
        end
        return this_group
      end

      def can_we_get_the_group? contract, group_id
        behav = send_query(contract, behav_slot(group_id))
        if behav == ('0x01' || '0x1' || '0x')
          return true
        end
        return false
      end

      def does_the_group_have_blobs? contract, group_id
        type = send_query(contract, type_slot(group_id))
        if type == ('0x01' || '0x1')
          return true
        end
        return false
      end

      def send_query contract, storage
        $eth.get_storage_at contract, storage
      end

      def ab? contract
        location     = send_query contract, '0x10'
        if location == '0x88554646ab'
          return true
        else
          return false
        end
      end

      def ba? contract
        location     = send_query contract, '0x10'
        if location == '0x88554646ba'
          return true
        else
          return false
        end
      end

      def get_the_blob blob, contract
        begin
          dn = blob[42..-1]
          blob_file = File.join(ENV['BLOBS_DIR'], dn)
          if File.exists? blob_file
            blob = File.read blob_file
            sha1_full = Digest::SHA1.hexdigest blob
            sha1_trun = sha1_full[0..23]
            if sha1_trun == dn
              @content << { contract => blob }
              puts "[C3D::#{Time.now.strftime( "%F %T" )}] Assembling >>\t" + contract
              return true
            end
          end
          return false
        rescue
          return false
        end
      end

      def prev_link_slot group_id
        slot = "0x" + ((group_id.hex + 0x1).to_s(16))
      end

      def type_slot group_id
        slot = "0x" + ((group_id.hex + 0x3).to_s(16))
      end

      def behav_slot group_id
        slot = "0x" + ((group_id.hex + 0x4).to_s(16))
      end

      def content_slot group_id
        slot = "0x" + ((group_id.hex + 0x5).to_s(16))
      end

      def address_guard contract
        contract = "0x#{contract}" unless contract[0..1] == '0x'
      end
  end
end