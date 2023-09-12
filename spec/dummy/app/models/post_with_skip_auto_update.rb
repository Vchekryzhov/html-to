class PostWithSkipAutoUpdate < ActiveRecord::Base
  def self.table_name
    :posts
  end
  include HtmlTo
  html_to HtmlTo::DummySerializer, skip_auto_update: true
end
