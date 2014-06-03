#!/usr/bin/env ruby

module Getter
  extend self

  def get puller, blob_id
    @puller = puller
    if blob_id[0..1] == '0x'
      blob_id = blob_id[2..-1]
    end
    btih    = blob_id[0..39]
    dn      = blob_id[40..-1]
    mag_link = "magnet:?xt=urn:btih:" + btih + "&dn=" + dn
    @puller.create @tor_file
  end
end