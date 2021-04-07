# html-to
# install
``` ruby
gem 'html_to'
```
And also you need headless browser chrome

Ubuntu:
``` bash
sudo apt install -y chromium-browser
```

Debian:
```bash
apt-get install chromium chromium-l10n
```

# Get Started
### Prepare your model
1) do migrate string field for uploader

and add start to your model, what you want use
``` ruby
@@share_uploader = "share_image"
@@share_template = 'share/post'
include HtmlTo
```

### creating template file

you need create, on path ```@@share_template``` how example share/post will be ```app/views/share/post.html.erb```

######template file example:
``` html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
	<style>

		body {
			margin: 0;
		}
		.image {
			background-size: cover;
			position: absolute;
      float: left;
      top: 0px;
      width: 1200px;
      height: 630px;
      object-fit: y-repeat;

    }
    .description{
      position: absolute;
      font-size: 48px;
      z-index: 1;
    }

	</style>
</head>
<body>
	<div class="root">
    <img class='image' src="https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?ixid=MXwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1489&q=80">
    <p class="description">
      <%=obj.attributes%>
      </p>
	</div>
</body>
</html>

```
In your template file you has access to your object via @obj

###### Assets, font, etc
Headless browser will be start from Rails public path, all local assets should be access in the public folder.
