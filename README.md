# html-to
# install
``` ruby
gem 'html_to', git: 'git@github.com:Vchekryzhov/html-to.git', require: 'html_headless'
```

# Get Started

1)Создать html.erb файл со стилями в самом файле и путями до картинки на сервере.
> /app/view/share/post.html.erb
``` html
<p> <%= @obj.title %> </p>
<img src="@obj.preview_image.path" >
<style >
  .
  .
  .
</style>
```
2) В модели куда будут подключены шеры создать колбак на коммит
``` ruby
   after_commit HtmlHeadless.callback_method

  define_method(HtmlHeadless.callback_method) do
    SharingImageGenerate.perform_async(id, self.class.to_s, 'share/post')
  end
```
2) Создать асинхронный сервис
``` ruby
class SharingImageGenerate
  require 'erb'
  include Sidekiq::Worker
  sidekiq_options queue: 'default'
  def perform(id, class_name, template)
    @obj = class_name.constantize.find(id)
    HtmlHeadless.new(template).to_image(@obj, :share_image)
  end
end

```

После выполнения скриншот отрисованого html сохранится в uploader :share_image
