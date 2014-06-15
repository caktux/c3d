#!/usr/bin/env ruby

module C3D
  module Utility
    extend self

    def save_key
      key = $eth.get_key
      config_file  = File.join(ENV['HOME'], '.epm', 'c3d-config.json')
      config = JSON.load(File.read(config_file))
      config["primary_account_key"] = key if config["primary_account_key"] != key
      ENV['ETH_KEY'] = config["primary_account_key"]
      File.open(config_file, 'w'){|f| f.write(JSON.pretty_generate(config))}
    end
  end
end