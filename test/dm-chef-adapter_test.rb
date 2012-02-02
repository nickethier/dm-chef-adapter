require 'minitest/spec'
require 'dm-core'
require 'dm-chef-adapter'

describe DataMapper::Adapters::ChefAdapter do
  before do
    DataMapper.setup(:default,
      :adapter => 'chef',
      :node_name => 'chef-webui',                       #this needs to also match a client client
      :client_key => '/etc/chef/webui.pem',    #this key ,ust match the client from above
      :chef_server_url => 'http://localhost:4000/' #url to the chef server api
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
