#!/usr/bin/env ruby

require 'celluloid/autostart'

class Subscribe
  include Celluloid

  def initialize
    @parse = JSON.load File.read ENV['WATCH_FILE']
    @purge = JSON.load File.read ENV['IGNORE_FILE']
    TreeBuilder.new @parse, @purge
  end
end