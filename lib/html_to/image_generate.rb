require 'fileutils'
require_relative 'chromium'
require 'erb'

class HtmlTo::ImageGenerate
  include HtmlTo::Chromium
  def call(record, serializer, options)
    generate_template(record, serializer, options[:template])
    take_screenshot(options[:width], options[:height])
    attach_image(record, options[:image_name])
  rescue StandardError
    raise
  ensure
    FileUtils.rm_f(html_file_path)
    FileUtils.rm_f(optimize_screenshot) if optimize_screenshot
    FileUtils.rm_f(screenshot_file_path)
  end

  def generate_template(record, serializer, template)
    object = serializer.constantize.new(record)
    html = ERB.new(File.read(template)).result(binding)
    File.write(html_file_path, html)
  end

  def take_screenshot(width, height)
    cmd = <<~BASH.chomp
      #{HtmlTo::Chromium.execute_path} \
      --headless \
      --screenshot=#{screenshot_file_path} \
      --window-size=#{width},#{height} \
      --disable-gpu \
      --disable-features=NetworkService #{html_file_path}
    BASH

    %x(#{cmd})
    raise StandardError, "html_to error result = #{$CHILD_STATUS}; command = #{cmd}" unless chromium_run_success?
  end

  def attach_image(record, image_name)
    record.send(image_name).purge
    record.html_to_skip_meta_image_generate = true
    record.send(image_name).attach(io: optimize_screenshot, filename: optimize_screenshot, content_type: 'image/png')
  end

  def html_file_path
    @html_file_path ||= Rails.root.join('tmp').join("#{SecureRandom.urlsafe_base64.downcase}.html")
  end

  def screenshot_file_path
    @screenshot_file_path ||= Rails.root.join('tmp').join("#{SecureRandom.urlsafe_base64.downcase}.png")
  end

  def optimize_screenshot
    return nil unless File.exist?(screenshot_file_path)

    @optimize_screenshot ||= if image_processing_installed?
                               ImageProcessing::MiniMagick
                                 .source(screenshot_file_path)
                                 .convert('jpg')
                                 .saver(quality: 85)
                                 .call

                             else
                               screenshot_file_path
                             end
  end

  private

  def chromium_run_success?
    $CHILD_STATUS.success?
  end

  def image_processing_installed?
    Gem::Specification.find_by_name('image_processing')
  rescue Gem::LoadError
    puts '[html-to] image will not processing because gem image_processing is not installed'
    false
  else
    true
  end
end
