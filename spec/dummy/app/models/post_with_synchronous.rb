class PostWithSynchronous < ActiveRecord::Base
  def self.table_name
    :posts
  end
  include HtmlTo
  html_to HtmlTo::DummySerializer, synchronous: true
end
