class HtmlToSerializer < HtmlTo::Serializer
  # you can have access to serialized record via object

  def title
    object.title
  end

  def background_image
    'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?ixid=MXwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&q=80'
  end
end
