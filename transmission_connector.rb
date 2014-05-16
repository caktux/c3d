#!/usr/bin/env ruby
# This is based off of work by fguillen for the transmission_api gem here: https://github.com/fguillen/TransmissionApi
require 'json'
require 'yaml'
require 'httparty'

class TransmissionApi
  attr_accessor :session_id
  attr_accessor :url
  attr_accessor :basic_auth
  attr_accessor :fields
  attr_accessor :debug_mode

  TORRENT_FIELDS = [
    "id",
    "name",
    "totalSize",
    "isFinished",
    "percentDone",
  ]

  def initialize(opts)
    @url = opts[:url]
    @fields = opts[:fields] || TORRENT_FIELDS
    @basic_auth = { :username => opts[:username], :password => opts[:password] } if opts[:username]
    @session_id = "NOT-INITIALIZED"
    @debug_mode = opts[:debug_mode] || false
  end

  def all
    log ("Getting All Torrents"), true

    response =
      post(
        :method => "torrent-get",
        :arguments => {
          :fields => fields
        }
      )

    response["arguments"]["torrent-added"]
  end

  def find(id)
    log ("Getting Torrent ID >> "+ "#{id}"), true

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

  def create(filename)
    log ("Wrote >> "+ "#{filename}"), true

    response =
      post(
        :method => "torrent-add",
        :arguments => {
          :filename => filename,
          :'download-dir' => BLOBS_DIR,
          :'peer-limit' => 99
        }
      )

    response["arguments"]["torrent-added"]
  end

  def destroy(id)
    log ("Remove Torrent ID >> "+ "#{id}"), true

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
        puts "[OWIG3::#{Time.now.strftime( "%F %T" )}] #{message}"
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