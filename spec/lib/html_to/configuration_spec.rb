describe HtmlTo::Configuration do
  it 'is possible to provide config options' do
    described_class.config do |c|
      expect(c).to eq(described_class)
    end
  end

  describe 'parameters' do
    let(:fake_class) { class_double('HtmlTo::Configuration') }

    it 'is possible to set chromium_path' do
      expect(fake_class).to receive(:chromium_path=).with('/bin/fake-chromium')
      fake_class.chromium_path = '/bin/fake-chromium'
    end
  end
end
