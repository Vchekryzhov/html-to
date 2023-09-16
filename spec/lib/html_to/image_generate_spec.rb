# image_generate_spec.rb
require 'fileutils'

describe HtmlTo::ImageGenerate do
  subject { described_class.new }

  let(:record) { double }
  let(:serializer) { double }
  let(:options) { { template: 'template.html', width: 800, height: 600, image_name: 'image_name' } }

  before do
    allow(FileUtils).to receive(:rm_f)
    allow(File).to receive(:write)
    allow(HtmlTo::Chromium).to receive(:execute_path)
    allow(record).to receive(:send)
    allow(record).to receive(:html_to_skip_meta_image_generate=)
    allow(record).to receive(:purge)
    allow(serializer).to receive(:constantize).and_return(double)
    allow(ImageProcessing::MiniMagick).to receive(:source).and_return(ImageProcessing::MiniMagick)
    allow(ImageProcessing::MiniMagick).to receive(:convert).and_return(ImageProcessing::MiniMagick)
    allow(ImageProcessing::MiniMagick).to receive(:saver).and_return(ImageProcessing::MiniMagick)
    allow(ImageProcessing::MiniMagick).to receive(:call).and_return('optimized_image.jpg')
    allow(File).to receive(:read).and_return('<html>template</html>')
  end

  describe '#call' do
    context 'when everything is successful' do
      it 'generates HTML, takes a screenshot, and attaches an image' do
        expect(subject).to receive(:generate_template).with(record, serializer, options[:template], options[:width], options[:height])
        expect(subject).to receive(:take_screenshot).with(options[:width], options[:height])
        expect(subject).to receive(:attach_image).with(record, options[:image_name])

        subject.call(record, serializer, options)
      end

      it 'cleans up temporary files' do
        allow(File).to receive(:exist?).with(subject.screenshot_file_path).and_return true
        expect(FileUtils).to receive(:rm_f).with(subject.html_file_path)
        expect(FileUtils).to receive(:rm_f).with(subject.screenshot_file_path)
        expect(FileUtils).to receive(:rm_f).with('optimized_image.jpg')
        allow(subject).to receive(:generate_template)
        allow(subject).to receive(:take_screenshot)
        allow(subject).to receive(:attach_image)
        subject.call(record, serializer, options)
      end
    end

    context 'when an error occurs during execution' do
      before do
        expect(subject).to receive(:generate_template).and_raise(StandardError)
      end

      it 're-raises exceptions' do
        expect { subject.call(record, serializer, options) }.to raise_error(StandardError)
      end

      it 'cleans up temporary files' do
        expect(FileUtils).to receive(:rm_f).with(subject.html_file_path)
        expect(FileUtils).to receive(:rm_f).with(subject.screenshot_file_path)
        expect(FileUtils).not_to receive(:rm_f)
        allow(subject).to receive(:generate_template)
        allow(subject).to receive(:take_screenshot)
        allow(subject).to receive(:attach_image)
        expect { subject.call(record, serializer, options) }.to raise_error(StandardError)
      end
    end
  end

  describe '#generate_template' do
    it 'generates an HTML file' do
      allow(serializer).to receive(:constantize).and_return(serializer)
      allow(serializer).to receive(:new).with(record).and_return(serializer)

      expect(File).to receive(:write).with(subject.html_file_path, '<html>template</html>')

      subject.generate_template(record, serializer, options[:template], options[:width], options[:height])
    end
  end

  describe '#take_screenshot' do
    it 'executes Chromium command to take a screenshot' do
      allow(HtmlTo::Chromium).to receive(:execute_path).and_return('/path/to/chromium')

      expect(subject).to receive(:`).with(
        "/path/to/chromium --headless --screenshot=#{subject.screenshot_file_path} --window-size=800,600 --disable-gpu --disable-features=NetworkService #{subject.html_file_path}"
      )
      expect(subject).to receive(:chromium_run_success?).and_return(true)
      subject.take_screenshot(options[:width], options[:height])
    end

    it 'raises an error if the Chromium command fails' do
      expect(HtmlTo::Chromium).to receive(:execute_path).and_return('/path/to/chromium')
      expect(subject).to receive(:`).with(
        "/path/to/chromium --headless --screenshot=#{subject.screenshot_file_path} --window-size=800,600 --disable-gpu --disable-features=NetworkService #{subject.html_file_path}"
      )
      expect(subject).to receive(:chromium_run_success?).and_return(false)
      expect { subject.take_screenshot(options[:width], options[:height]) }.to raise_error(StandardError)
    end
  end

  describe '#attach_image' do
    it 'purges the existing image' do
      attachment_double = double
      expect(record).to receive(:send).twice.with(options[:image_name]).and_return(attachment_double)
      expect(attachment_double).to receive(:purge)
      allow(attachment_double).to receive(:attach)
      subject.attach_image(record, options[:image_name])
    end

    it 'attaches the optimized screenshot as an image' do
      attachment_double = double
      expect(attachment_double).to receive(:attach).with(io: 'optimized_image.jpg', filename: 'optimized_image.jpg', content_type: 'image/png').and_return(true)
      allow(attachment_double).to receive(:purge)
      expect(record).to receive(:send).twice.with(options[:image_name]).and_return(attachment_double)

      allow(subject).to receive(:optimize_screenshot).and_return('optimized_image.jpg')

      subject.attach_image(record, options[:image_name])
    end
  end

  describe '#html_file_path' do
    it 'returns the path to the HTML file' do
      expect(subject.html_file_path.to_s).to match(%r{#{Rails.root}/tmp/[a-zA-Z0-9_-]+\.html})
    end
  end

  describe '#screenshot_file_path' do
    it 'returns the path to the screenshot file' do
      expect(subject.screenshot_file_path.to_s).to match(%r{#{Rails.root}/tmp/[a-zA-Z0-9_-]+\.png})
    end
  end

  describe '#optimize_screenshot' do
    context 'when screenshot file is not exist' do
      it 'return nil' do
        allow(File).to receive(:exist?).with(subject.screenshot_file_path).and_return false
        expect(subject.optimize_screenshot).to eq nil
      end
    end

    context 'when image_processing is installed' do
      it 'optimizes the screenshot using MiniMagick' do
        allow(File).to receive(:exist?).with(subject.screenshot_file_path).and_return true
        expect(subject).to receive(:image_processing_installed?).and_return(true)

        expect(ImageProcessing::MiniMagick).to receive(:source).with(subject.screenshot_file_path).and_return(ImageProcessing::MiniMagick)
        expect(ImageProcessing::MiniMagick).to receive(:convert).with('jpg').and_return(ImageProcessing::MiniMagick)
        expect(ImageProcessing::MiniMagick).to receive(:saver).with(quality: 85).and_return(ImageProcessing::MiniMagick)
        expect(ImageProcessing::MiniMagick).to receive(:call).and_return('optimized_image.jpg')

        result = subject.optimize_screenshot

        expect(result).to eq('optimized_image.jpg')
      end
    end

    context 'when image_processing is not installed' do
      it 'returns the screenshot file path as-is' do
        allow(File).to receive(:exist?).with(subject.screenshot_file_path).and_return true
        expect(subject).to receive(:image_processing_installed?).and_return(false)

        result = subject.optimize_screenshot

        expect(result).to eq(subject.screenshot_file_path)
      end
    end
  end

  describe '#image_processing_installed?' do
    context 'when the image_processing gem is installed' do
      it 'returns true' do
        allow(Gem::Specification).to receive(:find_by_name).with('image_processing').and_return(true)

        result = subject.send(:image_processing_installed?)

        expect(result).to be_truthy
      end
    end

    context 'when the image_processing gem is not installed' do
      it 'returns false and prints a message' do
        allow(Gem::Specification).to receive(:find_by_name).with('image_processing').and_raise(Gem::LoadError)
        expect(subject).to receive(:puts).with('[html-to] image will not processing because gem image_processing is not installed')

        result = subject.send(:image_processing_installed?)

        expect(result).to be_falsey
      end
    end
  end
end
