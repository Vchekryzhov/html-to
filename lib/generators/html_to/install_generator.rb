# frozen_string_literal: true

require 'rails/generators'

module HtmlTo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('./templates', __dir__)

      desc 'Copy example of serializer to your app'

      def copy_initializer
        copy_file 'html_to_serializer.rb', 'app/serializers/html_to_serializer.rb'
      end
    end
  end
end
