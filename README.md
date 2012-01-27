Chef Datamapper Adapter
===========================

This is an experimental adapter for [datamapper](http://datamapper.org/) to use chef databags as a backend datastore.

Setup
------

There are three configuration options needed when you initialize the adapter.

```ruby
DataMapper.setup(:default,
  :adapter => 'chef',
  :node_name => 'mybox',                       #this needs to also match a client client
  :client_key => '/path/to/client/key.pem',    #this key ,ust match the client from above
  :chef_server_url => 'http://localhost:4000/' #url to the chef server api
)
```

Models
-------

Models do not need a serial nor do they need to have keys set. This is all taken care of by the adapter with a single added line.

```ruby
class Post
  include DataMapper::Resource

  property :title, String
  property :body, Text

  has n, :comments

  is :chef  #the secret sauce

end
```

DISCLAIMER
------------

This code is experimental and has not been fully tested. Use at your own risk.

License
-------
The code and documentation is distributed under the Apache 2 license (http://www.apache.org/licenses/LICENSE-2.0.html). Contributions back to the source are encouraged.

