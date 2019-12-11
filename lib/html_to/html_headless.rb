class HtmlTo::HtmlHeadless
  require 'fileutils'

  def to_image(obj, width=1200, height=630)
    @template = File.read(Rails.root.join('app/views').join(obj.class.class_variable_get(:@@share_template)+".html.erb"))
    html = ERB.new(@template.html_safe).result(binding)
    screenshot_file = Tempfile.new(['screen','.png'])
    screenshot_file = Tempfile.new(['screen','.jpg'])
    File.open(html_file_path, 'w+') {|f| f.write(html) }
    begin
      cmd = "'#{chrome}'
        --headless
        --screenshot=#{screenshot_file.path}
        --window-size=#{width},#{height}
        --disable-gpu
        --disable-features=NetworkService #{html_file_path}".gsub("\n",' ')
      `#{cmd}`
      if $?.success?
        obj.class.skip_callback(:commit, :after, :share_image_generate)
        obj.send("#{obj.class.class_variable_get(:@@share_uploader)}=", screenshot_file)
        obj.save
        obj.class.set_callback(:commit, :after, :share_image_generate)
      else
        raise "result = #{$?}; command = #{cmd}"
      end
    ensure
       FileUtils.rm(html_file_path)
       screenshot_file.close
       screenshot_file.unlink
    end
  end

  def chrome
    if RbConfig::CONFIG['host_os'] =~ /darwin/
      "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
    elsif RbConfig::CONFIG['host_os'] =~ /linux/
      "chromium-browser"
    else
      raise StandardError.new "host os don't detected"
    end
  end

  def html_file_path
    @path ||= Rails.public_path.join(SecureRandom.urlsafe_base64.downcase + ".html")
  end
end
