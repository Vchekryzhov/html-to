module HtmlTo
  module Configuration
    class << self
      attr_accessor :chromium_path
      attr_writer :global_templates_path

      def config
        yield self
      end
    end
  end
end
