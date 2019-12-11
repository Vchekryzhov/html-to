# html-to
# install
``` ruby
gem 'html_to', git: 'git@github.com:Vchekryzhov/html-to.git', require: 'html_headless'
```
``` bash
sudo apt install -y chromium-browser
```
# Get Started

1)Создать html.erb файл со стилями в самом файле и путями до картинки на сервере.
> /app/view/share/post.html.erb
``` html
<p> <%= obj.title %> </p>
<img src="obj.preview_image.path" >
<style >
  .
  .
  .
</style>
```
Html в headless браузере будет запускатся из папки /public все шрифты и дополнительные файлы нужно класть туда.

2) В модели куда будут подключены шеры подключить модуль, указать путь до html и указать имя аплодера 
``` ruby
  include HtmlTo
  @@share_template = 'share/post'
  @@share_uploader = 'meta_image'
```
