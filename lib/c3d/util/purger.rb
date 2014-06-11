#!/usr/bin/env ruby

class Purger
  include Celluloid

  def initialize blob
    begin
      btih = blob[2..41]
      dn   = blob[42..-1]
      link = "magnet:?xt=urn:btih:" + btih + "&dn=" + dn
      currently_downloading = $puller.all
      downloading = currently_downloading.select{|t| t["name"] == dn}.first["id"]
      $puller.destroy downloading if downloading
      blob_file = File.join(ENV['BLOBS_DIR'], dn)
      if File.exists? blob_file
        File.delete blob_file
      end
    rescue
      return
    end
  end
end