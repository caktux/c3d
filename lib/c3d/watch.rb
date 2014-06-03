#!/usr/bin/env ruby

# Queries:
#   * `subscribe-k`:    add a contract's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `unsubscribe-k`   remove a contract's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `ignore-k`        add a contract's blobs to the ignore list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `unignore-k`      remove a contract's blobs from the ignore list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)

class EyeOfZorax
  include Celluloid
  attr_accessor :subscribed, :ignored

  def initialize
    @subscribe_file = ENV['WATCH_FILE']
    @ignore_file = ENV['IGNORE_FILE']
    loader @subscribed, @subscribe_file
    loader @ignored, @ignore_file
  end

  def subscribe contract
    adder @subscribed, @subscribe_file, contract
  end

  def unsubscribe contract
    remover @subscribed, @subscribe_file, contract
  end

  def ignore contract
    adder @ignored, @ignore_file, contract
  end

  def unignore contract
    remover @ignored, @ignore_file, contract
  end

  private
    def loader object, file
      object = JSON.load File.read file
    end

    def saver object, file
      File.open(file, 'w'){ |f| f.write JSON.pretty_generate object }
    end

    def adder object, file, contract
      unless object.include? contract
        object << contract if contract.class == (String || Array)
        object.flatten if contract.class == Array
        saver object, file
        loader object, file
        return true
      else
        return false
      end
    end

    def remover object, file, contract
      if object.include? contract
        if contract.class == String
          object.delete contract
        elsif contract.class == Array
          contract.each{ |c| object.delete c }
        end
        saver object, file
        loader object, file
        return true
      else
        return false
      end
    end
end