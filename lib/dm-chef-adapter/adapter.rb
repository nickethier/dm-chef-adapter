require 'json'
require 'chef'
require 'dm-core'
require 'uuidtools'

module DataMapper
  module Is
    module Chef
      def is_chef(options={})
        property :id, String, :key => true, :default => ''
      end
    end
  end
  module Adapters
    class ChefAdapter < AbstractAdapter
      # @api semipublic
      def create(resources)
        resources.collect do |resource|
          if !Chef::DataBag.list.keys.include?(resource.class.storage_name)
	    databag = Chef::DataBag.new
            databag.name resource.class.storage_name
            databag.create
          end
          
          resource.id=@uuid.sha1_create(UUIDTools::UUID_DNS_NAMESPACE, ("%10.6f#{resource.class.storage_name}" % Time.now.to_f))
          if resource.instance_variables.include? '@_key' 
            resource.send :remove_instance_variable, :@_key
          end

          if !Chef::DataBag.load(resource.class.storage_name).keys.include?(resource.key.join('-'))
            databag_item = Chef::DataBagItem.new
            databag_item.data_bag resource.class.storage_name
            databag_item.raw_data = Chef::JSONCompat.from_json(resource.to_json)
            databag_item.create
          else
            raise "DataBagItem #{resource.class.storage_name}/#{resource.key.join('-')} already exists."
          end
        end.count
      end

      # @api semipublic
      def read(query)
        query.filter_records(records_for(query.model.storage_name))
      end

      def update(attributes, collection)
        fields = attributes_as_fields(attributes)
        read(collection.query).each do |doc|
          databag_item = Chef::DataBagItem.load collection.storage_name, doc["id"]
          databag_item.raw_data.merge! Chef::JSONCompat.from_json(fields.to_json)
          databag_item.save
        end
      end

      # @api semipublic
      def delete(collection)
        read(collection.query).each do |doc|
          databag_item = Chef::DataBagItem.load collection.storage_name, doc["id"]
          databag_item.destroy collection.storage_name, doc["id"]
        end
      end

      # @api semipublic
      def attributes_as_fields(attributes)
        pairs = attributes.map do |property, value|
          dumped = value.kind_of?(Module) ? value.name : property.dump(value)
          [ property.field, dumped ]
        end
        Hash[pairs]
      end

      private

      # @api semipublic
      def initialize(name, opts = {})
        super
        Chef::Config.configuration[:node_name] = opts["node_name"]
	Chef::Config.configuration[:client_key] = opts["client_key"]
	Chef::Config.configuration[:chef_server_url] = opts["chef_server_url"] if !opts["chef_server_url"].nil?
        @chef = Chef::REST.new(Chef::Config[:chef_server_url])
        @uuid = UUIDTools::UUID
      end

      # Retrieves all records for a model and yields them to a block.
      #
      # The block should make any changes to the records in-place. After
      # the block executes all the records are dumped back to the databag.
      #
      # @param [Model, #to_s] model
      #   Used to determine which file to read/write to
      #
      # @yieldparam [Hash]
      #   A hash of record.key => record pairs retrieved from the databag
      #
      # @api private
      def update_records(model)
        records = records_for(model)
        result = yield records
        write_records(model, records)
        result
      end

      # Read all records from a databag for a model
      #
      # @param [#storage_name] model
      #   The model/name to retieve records for
      #
      # @api private
      def records_for(model)
	records = []
	databag = chef_databag(model)
	if !databag.nil?
          chef_databag(model).keys.each do |key|
            records << Chef::DataBagItem.load(model, key).raw_data
          end
        end
        records
      end

      # Writes all records to a databag
      #
      # @param [#storage_name] model
      #   The model/name to write the records for
      #
      # @param [Hash] records
      #   A hash of record.key => record pairs to be written
      #
      # @api private
      def write_records(model, records)
        item = Chef::DataBagItem.load(model. records["id"])
        item.from_hash records
        item.save
      end

      # Given a model, gives the databag to be used for record storage
      #
      # @example
      #   chef_databag(Article) #=> "Chef::DataBag"
      #
      # @param [#storage_name] model
      #   The model to be used to determine the databag.
      #
      # @api private
      def chef_databag(model)
        begin
          Chef::DataBag.load model
        rescue
          nil
        end
      end

    end # class ChefAdapter

    const_added(:ChefAdapter)
  end # module Adapters
  Model.append_extensions(Is::Chef)
end # module DataMapper

