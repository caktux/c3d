#!/usr/bin/env ruby

module C3D
  module EyeOfZorax
    extend self

    def subscribe contract
      subscribe_file = ENV['WATCH_FILE']
      subscribed = loader subscribe_file
      adder subscribed, subscribe_file, contract
    end

    def unsubscribe contract
      subscribe_file = ENV['WATCH_FILE']
      subscribed = loader subscribe_file
      remover subscribed, subscribe_file, contract
    end

    def ignore contract
      ignore_file = ENV['IGNORE_FILE']
      ignore = loader ignore_file
      adder ignored, ignore_file, contract
    end

    def unignore contract
      ignore_file = ENV['IGNORE_FILE']
      ignore = loader ignore_file
      remover ignored, ignore_file, contract
    end

    private
      def loader file
        begin
          j = JSON.load File.read file
        rescue
          j = []
        end
        j = [] unless j
        return j
      end

      def saver object, file
        File.open(file, 'w'){ |f| f.write JSON.pretty_generate object }
      end

      def adder object, file, contract
        unless object.include? contract
          object << contract if contract.class == (String || Array)
          object.flatten if contract.class == Array
          saver object, file
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
          return true
        else
          return false
        end
      end
  end
end