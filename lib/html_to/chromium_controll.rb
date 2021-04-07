module HtmlTo::ChromiumControll
  def chrome
    if RbConfig::CONFIG['host_os'] =~ /darwin/
      "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
    elsif RbConfig::CONFIG['host_os'] =~ /linux/
      release = IO.popen("lsb_release -i -s").read
      if release == "Debian\n"
        `dpkg -s chromium`
        raise "html_to message: You don't have chromium, please do apt install chromium"if !$?.success?
        'chromium'
      else
        `dpkg -s chromium-browser`
        raise "html_to message: You don't have chromium, please do apt install chromium"if !$?.success?
        'chromium-browser'
      end
    else
      raise StandardError.new "host os don't detected"
    end
  end
end
