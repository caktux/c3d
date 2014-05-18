#!/usr/bin/env ruby
# based off of work by @mukaibot here: https://github.com/mukaibot/mktorrent/blob/master/lib/mktorrent.rb
# and work by @Burgestrand here: https://gist.github.com/Burgestrand/1733611
# note `rhash` dependency

class Publish
  attr_accessor :tor_file, :blob_file, :sha1_trun

  def initialize blob, swarm_puller
    @piecelength = 32 * 1024
    prepare blob
    build
    write_torrent
    publish_torrent swarm_puller
  end

  private
    def prepare blob
      sha1_full = Digest::SHA1.hexdigest blob
      @sha1_trun = sha1_full[0..23]
      @tor_file  = File.join(TORRENTS_DIR, "#{sha1_trun}.torrent")
      @blob_file = File.join(BLOBS_DIR, sha1_trun)
      File.open(@blob_file, 'w'){|f| f.write(blob)}
      @files = [{ path: @blob_file.split('/'), length: File::open(@blob_file).size }]
    end

    def build
      @info = { :'created by' => "OWIG3",
                :'creation date' => DateTime.now.strftime("%s").to_i,
                encoding: "UTF-8",
                info: {  name: @files.first[:path].last,
                         :'piece length' => @piecelength,
                         length: @files.first[:length],
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
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Hashing Blob >> \t" + "#{file.join("/")}"
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

    def write_torrent
      File.open(@tor_file, 'w') do |torrentfile|
        torrentfile.write @info.bencode
      end
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Torrent Link >> \t" + "#{@tor_file}"
    end

    def publish_torrent swarm_puller
      torrent  = swarm_puller.create @tor_file
      btih     = torrent['hashString']
      mag_link = "magnet:?xt=urn:btih:" + btih + "&dn=" + @sha1_trun
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Magnet Link >> \t" + mag_link
    end
end
