require 'minitest/spec'
require 'dm-core'
require 'dm-chef-adapter'

describe DataMapper::Adapters::ChefAdapter do
  before do
    DataMapper.setup(:default,
      :adapter => 'chef',
      :node_name => ENV['CHEF_NODE_NAME'],        #this needs to also match a client client
      :client_key => ENV['CHEF_CLIENT_KEY'],      #this key must match the client from above
      :chef_server_url => ENV['CHEF_SERVER_URL']  #url to the chef server api
    )
    class TestModel
      include DataMapper::Resource

      is :chef

      property :int, Integer
      property :string, String
      property :bool, Boolean

    end

    DataMapper.finalize
  end

  describe "TestModel" do
    it "should have no records" do
      TestModel.all.count.must_equal 0
    end
  end
end
