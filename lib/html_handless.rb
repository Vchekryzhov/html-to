class HtmlHeadless

  def initialize(template)
    @template = File.read(Rails.root.join('app/views').join(template+".html.erb"))
  end

  def to_image(obj, uploader_method, width=500, height=500)
    width = 500
    height = 500
    html = ERB.new(@template.html_safe).result
    html_file = Tempfile.new('html')
    screenshot_file = Tempfile.new('screen')
    begin
      html_file.write(html)
      html_file.rewind
      cmd = "chromium-browser
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
end
