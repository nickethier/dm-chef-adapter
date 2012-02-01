require 'dm-core'
require 'dm-chef-adapter'

DataMapper.setup(:default, 
  :adapter => 'chef', 
  :node_name => "localbox", 
  :client_key => "/path/to/client/key.pem", 
  :chef_server_url => "http://chef.internal.net:4000/"
)

class Post
  include DataMapper::Resource
 
  is :chef
 
  property :title,	String
  property :body,	Text
  property :published,	Boolean

  has n, :comments
end

class Comment
  include DataMapper::Resource

  is :chef

  property :created_by,	String
  property :body,	Text
  
  belongs_to :post
end

DataMapper.finalize

post = Post.new(:title => "Datamapper is Awesome", :body => "Lorem ipsum ...", :published => true);
comment1 = Comment.new(:created_by => "Me", :body => "I agree")
post.comments << comment1
post.save



  
