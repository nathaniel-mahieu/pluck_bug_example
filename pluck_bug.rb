unless File.exist?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', github: 'rails/rails'
    gem 'arel', github: 'rails/arel'
    gem 'rack', github: 'rack/rack'
    gem 'i18n', github: 'svenfuchs/i18n'
    gem 'sqlite3'
  GEMFILE

  system 'bundle'
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts do |t|
  end

  create_table :comments do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 1, post.comments.count
    assert_equal 1, Comment.count
    assert_equal post.id, Comment.first.post.id
    
    
    pluck_values = Post.where("posts.id=1").joins(:comments).pluck("posts.id", "comments.id")
    
    assert_equal pluck_values[0][0], Comment.first.post.id
    assert_equal pluck_values[0][1], Comment.first.id
  end
end