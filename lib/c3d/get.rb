#!/usr/bin/env ruby

class Getter
  include Celluloid

  def initialize puller, btih, dn
    @puller = puller
    mag_link = "magnet:?xt=urn:btih:" + btih + "&dn=" + dn
    get_it
  end

  private
    def get_it
      torrent  = @puller.create @tor_file
    end
end