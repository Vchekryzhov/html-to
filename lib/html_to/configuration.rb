module HtmlTo
  module Configuration
    class << self
      attr_accessor :chromium_path

      def config
        yield self
      end
    end
  end
end
