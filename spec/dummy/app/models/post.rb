class Post < ActiveRecord::Base
  include HtmlTo
  html_to HtmlTo::DummySerializer
end
