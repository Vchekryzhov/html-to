class PostWithTwoImage < ActiveRecord::Base
  def self.table_name
    :posts
  end
  include HtmlTo
  html_to HtmlTo::DummySerializer do
    add_image :meta_image2, HtmlTo::DummySerializer
  end
end
