#!/usr/bin/env ruby

def check_system

  # Check for the SWARM_DIR Directory
  unless File.directory?(SWARM_DIR)
    Dir.mkdir SWARM_DIR
  end

  # Check for the TORRENTS_DIR Directory
  unless File.directory?(TORRENTS_DIR)
    Dir.mkdir TORRENTS_DIR
  end

  # Check for the BLOBS_DIR Directory
  unless File.directory?(BLOBS_DIR)
    Dir.mkdir BLOBS_DIR
  end

  # Check Ruby Bundled Assets & Set Asset Paths
  unless system 'bundle check > /dev/null'
    p 'Bundle is not installed. Installing now....'
    system 'rake install'
    p 'I have installed everything, but I need you to restart me'
    return false
  end

  p "System all setup and Ready."
end

def which cmd
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    }
  end
  return nil
end