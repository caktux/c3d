#!/usr/bin/env ruby

# Transactions:
#   * `add-blob-to-k`:  add blob to contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `add-blob-to-g`:  add blob to group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `rm-blob-from-g`: remove blob from contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)

class EthereumAPI
  include Celluloid::Autostart
  attr_accessor :session_id, :url, :basic_auth, :debug_mode

  def initialize opts
    @url = opts[:url]
    #@basic_auth = { :username => opts[:username], :password => opts[:password] } if opts[:username]
    @debug_mode = opts[:debug_mode] || false
  end


  def add_blob_to_k blob_id, contract_id
    log ("[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Adding Blob to Contract >>\t#{blob_id}\t#{contract_id}"), true
    transaction = {}
    transaction['recipient'] = contract_id
    transaction['data'] = #TODO
    response = post_transaction transaction
    response
  end

  def add_blob_to_g blob_id, contract_id, group_id
    log ("[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Adding Blob to Group >>\t#{blob_id}\t#{contract_id}\t#{group_id}"), true
    transaction = {}
    transaction['recipient'] = contract_id
    transaction['data'] = #TODO
    response = post_transaction transaction
    response
  end

  def rm_blob_from_g blob_id, contract_id, group_id
    log ("[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Removing Blob from Group >>\t#{blob_id}\t#{contract_id}\t#{group_id}"), true
    transaction = {}
    transaction['recipient'] = contract_id
    transaction['data'] = #TODO
    response = post_transaction transaction
    response
  end



  private
    def post_transaction transaction
      transaction['value'] = '0'
      transaction['gas'] = '1500'
      transaction['gasprice'] = '100000'
      JSON::parse( http_post( method: "transact", arguments: transaction ).body )
    end

    def

    def http_post opts
      post_options = {
        :body => opts.to_json,
        :headers => { "session-id" => session_id }
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
        @session_id = response.headers["session-id"]
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