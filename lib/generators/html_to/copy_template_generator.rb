# frozen_string_literal: true

require 'rails/generators'

module HtmlTo
  module Generators
    class CopyTemplateGenerator < Rails::Generators::Base
      source_root File.expand_path('../../views/html_to', __dir__)

      desc 'Copy templates'

      def copy_initializer
        copy_file 'image.html.erb', 'app/views/html_to/image.html.erb'
        copy_file 'circle.html.erb', 'app/views/html_to/circle.html.erb'
      end
    end
  end
end
