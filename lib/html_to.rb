module HtmlTo
  require_relative 'html_to/image_generate'
  require_relative 'html_to/meta_image_generate_job'
  require_relative 'html_to/configuration'
  require_relative 'html_to/chromium'
  require_relative 'html_to/serializer'
  class HtmlToImageSettings
    OPTIONS = %i[
      template width height image_name
    ].freeze
    DEFAULT_OPTIONS = {
      template: :circle,
      width: 1200,
      height: 630,
      image_name: :meta_image
    }.freeze
    attr_reader(*OPTIONS, :serializer)

    def initialize(klass, serializer, options, &block)
      @klass = klass
      @options = options
      validate_options
      @serializer = serializer.to_s
      setup_options
      instance_exec(&block) if block_given?
    end

    def validate_options
      @options.each_key { |opt| raise ArgumentError, "html_to error #{opt} is unknown option" unless OPTIONS.include? opt }
    end

    def setup_options
      OPTIONS.each do |k|
        instance_variable_set("@#{k}", @options[k] || DEFAULT_OPTIONS[k])
      end
      find_template_path!
    end

    def additional_images
      @additional_images || {}
    end

    def add_image(image_name, serializer, options = {})
      @additional_images ||= {}
      options[:image_name] = image_name
      @klass.class_eval do
        has_one_attached image_name
      end
      @additional_images[image_name] = HtmlToImageSettings.new(@klass, serializer, options)
    end

    def find_template_path!
      user_template = Rails.root.join('app/views/html_to').join("#{template}.html.erb")
      return user_template.to_s if File.file? user_template

      gem_template = File.expand_path("views/html_to/#{template}.html.erb", __dir__)

      return gem_template.to_s if File.file? gem_template

      raise ArgumentError, "html_to error Template file not found #{user_template} #{gem_template} "
    end
  end
  class << self
    attr_reader :included_in

    def included(klass)
      @included_in ||= []
      @included_in << klass
      @included_in.uniq!

      klass.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
  end

  module ClassMethods
    def self.extended(base)
      class << base
        alias_method :create_meta_images!, :html_to_create_meta_images! unless method_defined? :create_meta_images!
      end
      base.cattr_accessor :html_to_image_settings
    end

    def html_to_create_meta_images!
      all.each(&:html_to_create_meta_image!)
    end

    def html_to(serializer, options = {}, &block)
      after_validation :html_to_mark_synchronous if options.delete(:synchronous) == true && respond_to?(:after_validation)
      after_validation :html_to_mark_skip_meta_image_generate if options.delete(:skip_auto_update) == true && respond_to?(:after_validation)

      self.html_to_image_settings = HtmlToImageSettings.new(self, serializer, options, &block)
      class_eval do
        has_one_attached options[:image_name] || html_to_image_settings.image_name
      end
    end
  end

  module InstanceMethods
    def self.included(base)
      base.attr_accessor :html_to_skip_meta_image_generate
      base.instance_eval do
        alias_method :create_meta_image!, :html_to_create_meta_image! unless method_defined? :create_meta_images!
      end
      base.after_commit :html_to_create_meta_image!, unless: :html_to_skip_meta_image_generate
    end

    def html_to_create_meta_image!
      share_images_settings = [self.class.html_to_image_settings, *self.class.html_to_image_settings.additional_images.values].flatten
      share_images_settings.each do |image_settings|
        generator_args = [
          id, self.class.name, image_settings.serializer, {
            image_name: image_settings.image_name,
            width: image_settings.width,
            height: image_settings.height,
            template: image_settings.find_template_path!
          }
        ]
        if html_to_synchronous?
          MetaImageGenerateJob.perform_now(*generator_args)
        else
          MetaImageGenerateJob.perform_later(*generator_args)
        end
      end
    end

    private

    def html_to_mark_synchronous
      @html_to_synchronous = true
    end

    def html_to_mark_skip_meta_image_generate
      @html_to_skip_meta_image_generate = true
    end

    def html_to_synchronous?
      @html_to_synchronous
    end
  end
end
