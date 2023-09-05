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

    it 'path in configuration' do
      expect(described_class.execute_path).to eq 'test-path'
    end
  end
end
