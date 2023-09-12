module HtmlTo
  class DummySerializer
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def title
      :kek
    end
  end
end
