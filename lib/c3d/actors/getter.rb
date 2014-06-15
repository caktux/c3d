#!/usr/bin/env ruby

module C3D
  module Getter
    extend self

    def get blob_id
      if blob_id[0..1] == '0x'
        blob_id = blob_id[2..-1]
      end
      btih    = blob_id[0..39]
      dn      = blob_id[40..-1]
      mag_link = "magnet:?xt=urn:btih:" + btih + "&dn=" + dn
      $puller.create mag_link
      puts "[C3D::#{Time.now.strftime( "%F %T" )}] Getting >>\t\t" + mag_link
    end
  end
end