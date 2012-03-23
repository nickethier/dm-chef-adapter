# vim: set ts=2 et sw=2 sts=2 sta filetype=ruby :
require 'dm-core'
require 'celluloid'
require 'dalli'
require 'chef'

module DataMapper
  module Chef
    class Cache
      include Celluloid
    
      def initialize(url)
        @cache = Dalli::Client.new(url)
      end
  
      def sync(model)
        puts "in sync"
        records = []
        begin
          databag = ::Chef::DataBag.load model
          databag.keys.each do |key|
            records << ::Chef::DataBagItem.load(model, key).raw_data
          end
        rescue => e
          raise "Something happened when trying to sync cache for model #{model}"
        end
        puts records
        @cache.set model, records
      end

      def set(*args)
        @cache.set *args
      end

      def get(*args)
        @cache.get *args
      end

      def delete(*args)
        @cache.delete *args
      end
    end
  end
end
