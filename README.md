[![codecov](https://codecov.io/gh/Vchekryzhov/html-to/graph/badge.svg?token=27NK3S64MS)](https://codecov.io/gh/Vchekryzhov/html-to)
[![build](https://github.com/vchekryzhov/html-to/actions/workflows/ruby.yml/badge.svg)](https://github.com/vchekryzhov/html-to/actions/workflows/ruby.yml/badge.svg)
[![Gem Version](https://img.shields.io/gem/v/html_to.svg)](https://rubygems.org/gems/html_to)

# HtmlTo 🔥

HtmlTo is a gem for Rails that allows you to generate images from an HTML file.💡

## 📋 Table of Contents

- [Installation](#Installation)🚀
- [Usage](#basic-usage) 📖
- [Advanced usage](#advanced-usage) 🧰


## Installation

You need to have Chrome or Chromium installed 🛠️


Ubuntu:
``` bash
sudo apt install -y chromium-browser
```
Debian:
```bash
apt-get install chromium chromium-l10n
```
add gem to your gemfile
```ruby
gem 'html_to'
```
copy example serializer with
```bash
 rails generate html_to:install
```

### optional
for set path to chromium executable 
```ruby
#confg/initializers/html_to.rb
HtmlTo::Configuration.config do |config|
  config.chromium_path = './path-to-executable'
end
```

## Basic usage
Add to your model 📖

```ruby
  include HtmlTo
  html_to HtmlToSerializer
```
Now after save your model new image will generated and attached to ```meta_image``` in your model

## Advanced usage
available options for customizations 🧰
```ruby
  html_to HtmlTo::DummySerializer, image_name: :my_image, template: :image
```
| option             | descriotions                               | default    |
|--------------------|--------------------------------------------|------------|
| `image_name`       | name of attachment                         | meta_image |
| `template`         | HTML template                              | circle     |
| `synchronous`      | Run image generation job not in background | false      |
| `skip_auto_update` | skip auto update after save                | false      |
| `width`            | width of image                             | 1200       |
| `height`           | height of image                            | 630        |

### template customization
there are two templates available `circle` and `image` for copy to your project:
```bash
rails generate html_to:copy_template
```
you can add your own template to `app/views/html_to/*`
