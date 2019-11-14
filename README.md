# html-to
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
2) Создать асинхронный сервис
``` ruby
class GenerateSharingImage
  initialize(id)
  @obj = Post.find(id)
  HtmlHeadless.new('share/post').to_image(@obj, :share_image)
end
```

После выполнения скриншот отрисованого html сохранится в uploader :share_image
