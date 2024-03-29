RSpec.describe HtmlTo, type: :job do
  shared_examples 'successfully generation' do
    it 'save image after create model' do
      subject.save
      expect(subject.meta_image.attached?).to eq true
    end
  end

  shared_examples 'removing old images after generation' do
    it 'remove old image after generation' do
      subject.save
      first_image_path = ActiveStorage::Blob.service.path_for(subject.meta_image.key)
      expect(subject.meta_image.attached?).to eq true
      subject.save
      expect(File).not_to exist(first_image_path)
    end
  end

  context 'with default parameters' do
    subject { dummy_class.new }

    let(:dummy_class) { Post }

    it_behaves_like 'successfully generation'
    it_behaves_like 'removing old images after generation'
  end

  context 'with options' do
    subject { dummy_class.new }

    let(:dummy_class) { PostWithOptions }

    it_behaves_like 'successfully generation'
    it_behaves_like 'removing old images after generation'
  end

  context 'with bad options' do
    subject { dummy_class.new }

    let(:dummy_class) do
      Class.new(ApplicationRecord) do
        def self.table_name
          :posts
        end
        include HtmlTo
        html_to HtmlTo::DummySerializer, unknown_option: 100
      end
    end

    it 'raise with unknown options' do
      expect { subject.save }.to raise_error(ArgumentError, 'html_to error unknown_option is unknown option')
    end
  end

  context 'with two images' do
    subject { dummy_class.new }

    let(:dummy_class) { PostWithTwoImage }

    it 'generate two images' do
      subject.save
      expect(subject.meta_image.attached?).to eq true
      expect(subject.meta_image2.attached?).to eq true
    end
  end

  context 'with syncronous' do
    subject { dummy_class.new }

    let(:dummy_class) { PostWithSynchronous }

    it_behaves_like 'successfully generation'
    it_behaves_like 'removing old images after generation'
  end

  context 'when image_processing_is_not_instasll' do
    subject { dummy_class.new }

    before do
      allow_any_instance_of(HtmlTo::ImageGenerate).to receive(:image_processing_installed?).and_return(false)
    end

    let(:dummy_class) { Post }

    it_behaves_like 'successfully generation'
    it_behaves_like 'removing old images after generation'
  end

  context 'with skip auto update' do
    subject { dummy_class.new }

    let(:dummy_class) { PostWithSkipAutoUpdate }

    it 'is not generated' do
      subject.save
      expect(subject.meta_image.attached?).to eq false
    end
  end

  context 'correct destroy' do
    subject { dummy_class.new }

    let(:dummy_class) { Post }

    it 'is not generated' do
      subject.save
      subject.destroy
    end
  end
end
