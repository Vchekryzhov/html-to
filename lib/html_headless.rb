class HtmlHeadless

  def initialize(template)
    @template = File.read(Rails.root.join('app/views').join(template+".html.erb"))
  end

  def to_image(obj, uploader_method, width=1200, height=630)
    html = ERB.new(@template.html_safe).result(binding)
    html_file = Tempfile.new(['share','.html'])
    screenshot_file = Tempfile.new(['screen','.jpg'])
    begin
      html_file.write(html)
      html_file.rewind
      cmd = "'#{chrome}'
        --headless
        --screenshot=#{screenshot_file.path}
        --window-size=#{width},#{height}
        --disable-gpu
        --disable-features=NetworkService #{html_file.path}".gsub("\n",' ')
      `#{cmd}`
      if $?.success?
        obj.send("#{uploader_method}=", screenshot_file)
        obj.save
      else
        raise "result = #{$?}; command = #{cmd}"
      end
    ensure
       html_file.close
       screenshot_file.close
       html_file.unlink
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
end
