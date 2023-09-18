require 'English'
module HtmlTo
  module Chromium
    def self.execute_path
      if Configuration.chromium_path.present?
        raise ArgumentError, "html_to error: not found chromium by path #{Configuration.chromium_path}" unless File.exist? Configuration.chromium_path

        return Configuration.chromium_path
      end

      path = if /darwin/.match?(RbConfig::CONFIG['host_os'])
               '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
             elsif /linux/.match?(RbConfig::CONFIG['host_os'])
               release = %x(lsb_release -i -s)
               %x(which chromium-browser)
               if release == "Debian\n"
                 which_path = %x(which chromium)
                 raise StandardError, "html_to error: You don't have chromium, please do apt install chromium" unless $CHILD_STATUS.success?

               else
                 which_path = %x(which chromium-browser)
                 raise StandardError, "html_to error: You don't have chromium, please do apt install chromium-browser" unless $CHILD_STATUS.success?
               end
               which_path
             else
               raise StandardError, "html_to error host os don't detected"
             end
      raise StandardError, 'html_to error: chromium executable path not found' if path.blank?

      path.delete("\n")
    end

    def self.version
      %x(#{execute_path} --version)
    end
  end
end
