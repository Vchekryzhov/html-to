describe HtmlTo do
  subject { dummy_class.new }

  let(:dummy_class) { Post }

  describe '.html_to' do
    it 'active storage uploader attached' do
      expect(dummy_class.attachment_reflections['meta_image']).to be_truthy
    end

    it 'html_to_image_settings added' do
      expect(subject.html_to_image_settings).to be_a HtmlTo::HtmlToImageSettings
    end
  end

  describe 'HtmlToImageSettings#find_template_path!' do
    it 'return path to gem template' do
      expect(subject.html_to_image_settings.find_template_path!).to end_with('lib/views/html_to/white.html.erb')
    end

    it 'return path to user template' do
      allow(subject.html_to_image_settings).to receive(:template).and_return(:dummy_template)
      expect(subject.html_to_image_settings.find_template_path!).to end_with('app/views/html_to/dummy_template.html.erb')
    end

    it 'raise error when template is not exists' do
      allow(subject.html_to_image_settings).to receive(:template).and_return(:non_exist_template)
      expect { subject.html_to_image_settings.find_template_path! }.to raise_error(ArgumentError)
    end
  end

  describe 'HtmlToImageSettings#setup_options' do
    it 'setup default options' do
      default_options = subject.html_to_image_settings.class::DEFAULT_OPTIONS
      expect(subject.html_to_image_settings.width).to eq default_options[:width]
      expect(subject.html_to_image_settings.height).to eq default_options[:height]
      expect(subject.html_to_image_settings.template).to eq default_options[:template]
      expect(subject.html_to_image_settings.image_name).to eq default_options[:image_name]
    end

    context 'with user options' do
      let(:dummy_class) { PostWithOptions }

      it 'assign correct' do
        expect(subject.html_to_image_settings.width).to eq 100
      end
    end
  end

  describe 'HtmlToImageSettings#validate_options' do
    let(:dummy_class) do
      Class.new(ApplicationRecord) do
        def self.table_name
          :posts
        end
        include HtmlTo
        html_to HtmlTo::DummySerializer, unknown_option: 100
      end
    end

    it 'unknown options' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end

  describe 'HtmlToImageSettings#add_image' do
    let(:dummy_class) { PostWithTwoImage }

    it 'active storage additional uploader attached' do
      expect(dummy_class.attachment_reflections['meta_image2']).to be_truthy
    end

    it 'has one additional image' do
      expect(subject.html_to_image_settings.additional_images.size).to eq 1
    end
  end

  describe '.create_meta_images!' do
    it 'is callable' do
      expect(dummy_class).to respond_to(:html_to_create_meta_images!)
    end

    it 'alias' do
      expect(dummy_class.method(:create_meta_images!).original_name).to eq(dummy_class.method(:html_to_create_meta_images!).original_name)
    end

    it 'calls #html_to_create_meta_image! on each object' do
      object1 = dummy_class.new
      object2 = dummy_class.new
      expect(object1).to receive(:html_to_create_meta_image!).once
      expect(object2).to receive(:html_to_create_meta_image!).once
      allow(dummy_class).to receive(:all).and_return([object1, object2])
      dummy_class.html_to_create_meta_images!
    end
    # rubocop:enable RSpec/MultipleExpectations
    # rubocop:enable RSpec/ExampleLength
  end

  describe 'synchronous_options' do
    context 'when set synchronous true' do
      let(:dummy_class) { PostWithSynchronous }

      it 'is with synchronous' do
        subject = dummy_class.new
        subject.valid?
        expect(subject.send(:html_to_synchronous?)).to be true
      end
    end

    context 'when set synchronous false' do
      let(:dummy_class) { Post }

      it 'is without syncronous' do
        subject = dummy_class.new
        subject.valid?
        expect(subject.send(:html_to_synchronous?)).to be_falsey
      end
    end
  end

  describe '#html_to_create_meta_image!' do
    it 'is callable' do
      expect(subject).to respond_to(:html_to_create_meta_image!)
    end

    it 'alias' do
      expect(subject.method(:create_meta_image!).original_name).to eq(subject.method(:html_to_create_meta_image!).original_name)
    end

    it 'added job to queue' do
      expect(HtmlTo::MetaImageGenerateJob).to receive(:perform_later).with(1, subject.class.name, 'HtmlTo::DummySerializer', hash_including(height: 630, image_name: :meta_image, template: %r{.*/html-to/lib/views/html_to/white.html.erb$}, width: 1200)
      )
      subject.save
    end

    context 'when synchronous' do
      let(:dummy_class) { PostWithSynchronous }

      it 'job run synchronous' do
        expect(HtmlTo::MetaImageGenerateJob).to receive(:perform_now).with(1, subject.class.name, 'HtmlTo::DummySerializer', hash_including(height: 630, image_name: :meta_image, template: %r{.*/html-to/lib/views/html_to/white.html.erb$}, width: 1200))
        subject.save
      end
    end
  end

  describe '#html_to_skip_meta_image_generate' do
    it 'is callable' do
      subject.html_to_skip_meta_image_generate = :test

      expect(subject.html_to_skip_meta_image_generate).to eq(:test)
    end

    it 'by default is false' do
      expect(subject.html_to_skip_meta_image_generate).to be_falsey
    end

    context 'when skip_auto_update is set to true' do
      let(:dummy_class) { PostWithSkipAutoUpdate }

      it 'is true' do
        subject.valid?
        expect(subject.html_to_skip_meta_image_generate).to eq true
      end
    end
  end

  describe '#html_to_mark_skip_meta_image_generate' do
    it 'is defined' do
      expect(dummy_class.private_method_defined?(:html_to_mark_synchronous)).to be(true)
    end
  end

  describe '#html_to_synchronous?' do
    it 'is defined' do
      expect(dummy_class.private_method_defined?(:html_to_synchronous?)).to be(true)
    end
  end
end
