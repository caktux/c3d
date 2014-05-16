#!/usr/bin/env ruby
# based off of work by @mukaibot here: https://github.com/mukaibot/mktorrent/blob/master/lib/mktorrent.rb
# and work by @Burgestrand here: https://gist.github.com/Burgestrand/1733611
# note `rhash` dependency

require 'digest/sha1'
require 'bencode'

# magnet:?xt=urn:btih:MZSTSMZUGQ4WCYRXHEZGIMBSHA4DGZRUGBQTOYZQGM4DQOLBMY4DAOLDMY2WKNZY&dn=09340e0ae0666063030b4bc3
# magnet:?xt=urn:btih:a800e8040f211dbca98a0f19801f2195d85c302f&dn=09340e0ae0666063030b4bc3

class Torrent
  def initialize filepath
    @tracker = ''
    @piecelength = 32 * 1024 # 512 KB
    @filehashes = []
    @size = 0
    @defaultdir = ""
    @files = [{ path: filepath.split('/'), length: File::open(filepath).size }]
    build
  end

  def write_torrent filename
    open(filename, 'w') do |torrentfile|
      torrentfile.write @info.bencode
    end
    torrent_file = "#{`pwd`.chomp}/#{filename}"
    puts "[OWIG3::#{Time.now.strftime( "%F %T" )}] Magnet Link >> " + "#{torrent_file}"
    torrent_file
  end

  private
    def build
      @info = { :'created by' => "OWIG3",
                :'creation date' => DateTime.now.strftime("%s").to_i,
                encoding: "UTF-8",
                :info => { :name => @files.first[:path].last,
                           :'piece length' => @piecelength,
                           :length => @files.first[:length],
                           :private => 0, #1 is private
                         }
              }
      @info[:info][:pieces] = ""
      i = 0
      read_pieces(@files.first[:path], @piecelength) do |piece|
        @info[:info][:pieces] += Digest::SHA1.digest(piece)
        i += 1
      end
    end

    def read_pieces(file, length)
      buffer = ""
      puts "[OWIG3::#{Time.now.strftime( "%F %T" )}] Hashing File Blob >> " + "#{file.join("/")}"
      File.open(file.join("/")) do |fh|
        begin
          read = fh.read(length - buffer.length)
          if (buffer.length + read.length) == length
            yield(buffer + read)
            buffer = ""
          else
            buffer += read
          end
        end until fh.eof?
      end
      yield buffer
    end
end
