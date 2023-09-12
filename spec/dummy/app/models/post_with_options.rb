class PostWithOptions < ActiveRecord::Base
  def self.table_name
    :posts
  end
  include HtmlTo
  html_to HtmlTo::DummySerializer, width: 100
end
