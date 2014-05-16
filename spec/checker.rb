#!/usr/bin/env ruby

require 'rubygems'
require 'cgi'
require 'openssl'

def require_gem(name)
  require(name)
rescue LoadError
  abort "[ERROR] Missing the '#{name}' gem, install it with 'gem install #{name}'"
end

require_gem 'bencode'
require_gem 'base32'
require_gem 'rack/utils'

# We cannot trust .torrent file data
ARGF.set_encoding 'BINARY'

# Read torrent from STDIN / ARGV filepath
torrent_data = ARGF.read

# Parse the torrent data
torrent = BEncode.load(torrent_data)

# Calculate the info_hash (actually, info_sha1 *is* the info_hash)
info_hash = torrent["info"].bencode
info_sha1 = OpenSSL::Digest::SHA1.digest(info_hash)

# Build the magnet link
params = {}
params[:xt] = "urn:btih:" << Base32.encode(info_sha1)
params[:dn] = CGI.escape(torrent["info"]["name"])

# params[:tr] = [] << to complement DHT we can add trackers too
magnet_uri  = "magnet:?xt=#{params.delete(:xt)}"
magnet_uri << "&" << Rack::Utils.build_query(params)

puts "Magnet URI for #{params[:dn]}:"
puts "  #{magnet_uri}"


# magnet:?xt=urn:btih:048ea0d1a27f702ba5e8f7890915d4d6a2454e20&dn=cdae42af3e2d9b7f208f8ec3
# magnet:?xt=urn:btih:048ea0d1a27f702ba5e8f7890915d4d6a2454e20&dn=cdae42af3e2d9b7f208f8ec3