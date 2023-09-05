describe HtmlTo::MetaImageGenerateJob, type: :job do
  describe '#perform' do
    let(:id) { 1 }
    let(:class_name) { 'DummyModel' }
    let(:serializer) { 'DummySerializer' }
    let(:options) { { some_option: 'value' } }
    let(:generator) { instance_double(HtmlTo::ImageGenerate, call: nil) }

    it 'calls HtmlTo::ImageGenerate.new.call with the correct arguments' do
      record = double('DummyModel')
      allow(class_name.constantize).to receive(:find).with(id).and_return(record)

      allow(HtmlTo::ImageGenerate).to receive(:new).and_return(generator)
      expect(generator).to receive(:call).with(record, serializer, options)

      described_class.perform_now(id, class_name, serializer, options)
    end

    it "queues the job in the 'html_to' queue" do
      expect(described_class.new.queue_name).to eq('html_to')
    end
  end
end
