class HtmlTo::HtmlHeadless
  require 'fileutils'

  def to_image(obj, width=1200, height=630)

    width = obj.class.class_variable_get(:@@html_to_width) if obj.class.class_variable_defined?(:@@html_to_width)
    height = obj.class.class_variable_get(:@@html_to_height) if obj.class.class_variable_defined?(:@@html_to_height)

    @template = File.read(Rails.root.join('app/views').join(obj.class.class_variable_get(:@@share_template)+".html.erb"))
    html = ERB.new(@template.html_safe).result(binding)
    File.open(html_file_path, 'w+') {|f| f.write(html) }
    begin
      cmd = "'#{chrome}'
        --headless
        --screenshot=#{screenshot_file_path}
        --window-size=#{width},#{height}
        --disable-gpu
        --disable-features=NetworkService #{html_file_path}".gsub("\n",' ')
      `#{cmd}`
      if $?.success?
        obj.skip_share_image_generate = true
        obj.send("#{obj.class.class_variable_get(:@@share_uploader)}=", File.open(screenshot_file_path))
        obj.save
      else
        raise "result = #{$?}; command = #{cmd}"
      end
    ensure
       FileUtils.rm(html_file_path)
       FileUtils.rm(screenshot_file_path)
    end
  end

  def chrome
    if RbConfig::CONFIG['host_os'] =~ /darwin/
      "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
    elsif RbConfig::CONFIG['host_os'] =~ /linux/
      release = IO.popen("lsb_release -i -s").read
      if release == "Debian\n"
        'chromium'
      else
        'chromium-browser'
      end
    else
      raise StandardError.new "host os don't detected"
    end
  end

  def html_file_path
    @path ||= Rails.public_path.join(SecureRandom.urlsafe_base64.downcase + ".html")
  end
  def screenshot_file_path
    @screenshot_file_path ||= Rails.public_path.join(SecureRandom.urlsafe_base64.downcase + ".png")
  end
end
