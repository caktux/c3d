#!/usr/bin/env ruby
require 'spec_helper'

describe "Setting Up c3D" do

  describe C3D::SetupC3D, "running Setup Sequence" do
    it "should set the environment variables." do
      expect(ENV['SWARM_DIR']).to be
      expect(ENV['TORRENTS_DIR']).to be
      expect(ENV['BLOBS_DIR']).to be
      expect(ENV['WATCH_FILE']).to be
      expect(ENV['IGNORE_FILE']).to be
      expect(ENV['TORRENT_RPC']).to be
      expect(ENV['TORRENT_USER']).to be
      expect(ENV['TORRENT_PASS']).to be
      expect(ENV['UI_RESPOND']).to be
      expect(ENV['UI_ANNOUNCE']).to be
      expect(ENV['ETH_CONNECTOR']).to be
      expect(ENV['ETH_HOST']).to be
      expect(ENV['ETH_PORT']).to be
      expect(ENV['ETH_KEY']).to be
    end

    it "should build the default files and directories." do
      expect(File.directory? ENV['SWARM_DIR']).to    be_truthy
      expect(File.directory? ENV['TORRENTS_DIR']).to be_truthy
      expect(File.directory? ENV['BLOBS_DIR']).to    be_truthy
      expect(File.exists?    ENV['WATCH_FILE']).to   be_truthy
      expect(File.exists?    ENV['IGNORE_FILE']).to  be_truthy
    end
  end
end