class PostWithBadOptions < ActiveRecord::Base
  def self.table_name
    :posts
  end
  include HtmlTo
  html_to HtmlTo::DummySerializer, unknown_option: 100
end
