#!/usr/bin/env ruby

require 'bencode'
require 'digest/sha1'
require 'base32'

t = BEncode.load_file(ARGV[0])
f = BEncode.load_file(ARGV[1])
puts t
puts f