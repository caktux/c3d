#!/usr/bin/env ruby

module C3D
  class Subscribe
    include Celluloid

    def initialize
      @parse = JSON.load File.read ENV['WATCH_FILE']
      @purge = JSON.load File.read ENV['IGNORE_FILE']
      puts "[C3D::#{Time.now.strftime( "%F %T" )}] Parsing Watchlist"
      C3D::TreeBuilder.new @parse, @purge
    end
  end
end