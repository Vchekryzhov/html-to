module HtmlTo
  class MetaImageGenerateJob < ::ActiveJob::Base
    queue_as :default
    def perform(id, class_name, serializer, options)
      record = class_name.constantize.find(id)
      generator.call(record, serializer, options)
    end

    def generator
      HtmlTo::ImageGenerate.new
    end
  end
end
