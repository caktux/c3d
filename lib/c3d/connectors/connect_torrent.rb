#!/usr/bin/env ruby
# This is based off of work by fguillen for the transmission_api gem here: https://github.com/fguillen/TransmissionApi

class ConnectTorrent
  include Celluloid
  attr_accessor :session_id, :url, :basic_auth, :fields, :debug_mode

  TORRENT_FIELDS = [
    "id",
    "name",
    "totalSize",
    "isFinished",
    "percentDone",
  ]

  def initialize opts
    @url = opts[:url]
    @fields = opts[:fields] || TORRENT_FIELDS
    @basic_auth = { :username => opts[:username], :password => opts[:password] } if opts[:username]
    @debug_mode = opts[:debug_mode] || false
    @session_id = "c3d-torrent"
  end

  def all
    log ("[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Getting All Torrents"), true

    response =
      post(
        :method => "torrent-get",
        :arguments => {
          :fields => fields
        }
      )

    response["arguments"]["torrents"]
  end

  def find id
    log ("[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Getting Torrent ID >> "+ "#{id}"), true

    response =
      post(
        :method => "torrent-get",
        :arguments => {
          :fields => fields,
          :ids => [id]
        }
      )

    response["arguments"]["torrents"].first
  end

  def create filename
    log ("[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Adding Blob >>\t\t"+ "#{filename}"), true

    response =
      post(
        :method => "torrent-add",
        :arguments => {
          :filename => filename,
          :'download-dir' => ENV['BLOBS_DIR'],
          :'peer-limit' => 99
        }
      )

    response["arguments"]
  end

  def destroy id
    log ("[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Remove Torrent ID >> "+ "#{id}"), true

    response =
      post(
        :method => "torrent-remove",
        :arguments => {
          :ids => [id],
          :"delete-local-data" => true
        }
      )

    response
  end

  private
    def post(opts)
      JSON::parse( http_post(opts).body )
    end

    def http_post(opts)
      post_options = {
        :body => opts.to_json,
        :headers => { "x-transmission-session-id" => session_id }
      }
      post_options.merge!( :basic_auth => basic_auth ) if basic_auth

      log "url: #{url}"
      log "post_body:"
      log JSON.parse(post_options[:body]).to_yaml
      log "------------------"

      response = HTTParty.post( url, post_options )

      log_response response

      # retry connection if session_id incorrect
      if( response.code == 409 )
        log "changing session_id"
        @session_id = response.headers["x-transmission-session-id"]
        response = http_post(opts)
      end

      response
    end

    def log(message, override = false)
      if debug_mode || override
        puts "#{message}"
      end
    end

    def log_response(response)
      body = nil
      begin
        body = JSON.parse(response.body).to_yaml
      rescue
        body = response.body
      end

      headers = response.headers.to_yaml

      log "response.code: #{response.code}"
      log "response.message: #{response.message}"

      log "response.body_raw:"
      log response.body
      log "-----------------"

      log "response.body:"
      log body
      log "-----------------"

      log "response.headers:"
      log headers
      log "------------------"
    end
end