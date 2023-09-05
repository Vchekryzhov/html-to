describe HtmlTo::Serializer do
  let(:sample_object) { double('SampleObject') }
  let(:serializer) { described_class.new(sample_object) }

  describe '#initialize' do
    it 'assigns the object to the @object instance variable' do
      expect(serializer.object).to eq(sample_object)
    end
  end
end
