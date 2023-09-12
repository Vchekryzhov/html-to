describe HtmlTo::Chromium do
  describe '.version' do
    it 'chromium available' do
      described_class.version
    end
  end

  describe '.execute_path' do
    before do
      HtmlTo::Configuration.config do |config|
        config.chromium_path = 'test-path'
      end
    end

    after do
      HtmlTo::Configuration.config do |config|
        config.chromium_path = nil
      end
    end

    context 'path in configuration exists' do
      it 'return pass from configuration' do
        allow(File).to receive(:exist?).with('test-path').and_return(true)
        expect(described_class.execute_path).to eq 'test-path'
      end
    end

    context 'path in configuration non exists' do
      it 'return pass from configuration' do
        allow(File).to receive(:exist?).with('test-path').and_return(false)
        expect { described_class.execute_path }.to raise_error(ArgumentError)
      end
    end
  end
end
