#!/usr/bin/env ruby

class TreeBuilder
  include Celluloid
  attr_accessor :groups, :blobs, :parse, :purge

  def initialize parse=[], purge=[], debug=false
    @groups = 0
    @blobs  = 0
    @parsed = 0
    @purged = 0
    @parse = parse || []
    @purge = purge || []
    assemble_and_perform_queries
    print(@parsed.to_s + " || " + @purged.to_s + " || " + @groups.to_s  + " || " + @blobs.to_s + "\n") if debug
  end

  private

    def assemble_and_perform_queries
      until @parse.empty?
        get_the_contract @parse.shift
        @parse.uniq!
      end
      until @purge.empty?
        purge_the_contract @purge.shift
        @purge.uniq!
      end
    end

    def get_the_contract contract
      @parsed += 1
      if ab? contract
        get_ab_content contract
      elsif ba? contract
        get_ba_content contract
      end
    end

    def purge_the_contract contract
      @purged += 1
      if ab? contract
        purge_ab_content contract
      elsif ba? contract
        purge_ba_content contract
      end
    end

    def get_ab_content contract
      if can_we_get_the_k? contract
        blob = send_query contract, '0x13'
        get_the_blob blob unless do_i_have_it? blob
      end
    end

    def get_ba_content contract
      if can_we_get_the_k? contract
        get_data_model contract
        get_ui_files contract
        group = {}
        group[:prev] = send_query contract, '0x19'
        until group[:prev] == '0x30'
          group = get_the_group contract, group[:prev]
          get_the_blob group[:cont] unless do_i_have_it? group[:cont]
        end
      end
    end

    def purge_ab_content contract
      blob = send_query contract, '0x13'
      purge_the_blob blob
    end

    def purge_ba_content contract
      dm = send_query contract, '0x11'
      purge_the_blob dm
      ui = send_query contract, '0x12'
      @purge.push ui
      group = {}
      group = send_query contract, '0x19'
      until group == '0x30'
        group = purge_the_group contract, group
      end
    end

    def can_we_get_the_k? contract
      behav = send_query contract, '0x18'
      if behav == '0x01'
        return true
      elsif behav == '0x05'
        @purge.push contract
      end
      return false
    end

    def get_the_group contract, group_id
      @groups   += 1
      this_group = {}
      if can_we_get_the_group? contract, group_id
        if does_the_group_have_blobs? contract, group_id
          group_id[-1] = '5'
          this_group[:blob] = send_query contract, group_id
        end
        group_id[-1] = '1'
        this_group[:prev] = send_query contract, group_id
      else
        this_group[:prev] = '0x30'
      end
      return this_group
    end

    def purge_the_group contract, group_id
      @groups   += 1
      group_id[-1] = '5'
      blob = send_query contract, group_id
      purge_the_blob blob
      group_id[-1] = '1'
      send_query contract, group_id
    end

    def can_we_get_the_group? contract, group_id
      group_id[-1] = '4'
      behav = send_query contract, group_id
      if behav == '0x01'
        return true
      elsif behav == '0x05'
        group_id[-1] = '0'
        @purge.push group_id
      end
      return false
    end

    def does_the_group_have_blobs? contract, group_id
      group_id[-1] = '3'
      type = send_query contract, group_id
      if type == '0x'
        group_id[-1] = '0'
        @parse.push group_id
        return false
      elsif type == '0x01'
        group_id[-1] = '0'
        @parse.push group_id
        return true
      else
        return false
      end
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

    def do_i_have_it? blob
      begin
        dn   = blob[42..-1]
        f = File.exists?(File.join(ENV['BLOBS_DIR'], dn))
        @blobs += 1
      rescue
        return false
      end
      f
    end

    def get_the_blob blob
      begin
        btih = blob[2..41]
        dn   = blob[42..-1]
        link = "magnet:?xt=urn:btih:" + btih + "&dn=" + dn
        torrent  = $puller.create link
        return true
      rescue
        return false
      end
    end

    def purge_the_blob blob
      Purger.new blob
    end

    def get_data_model contract
      blob = send_query contract, '0x11'
      get_the_blob blob unless do_i_have_it? blob
    end

    def get_ui_files contract
      contract = send_query contract, '0x12'
      @parse.push contract
    end
end