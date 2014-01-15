module ApiHelper
  include ActionView::Helpers::DateHelper
  include GravatarImageTag

  def profile_image(email, options={})
    gravatar_image_url(email, { :size => 50, :default => 'identicon' }.merge(options))
  end

  def markdown(text)
    @renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @renderer.render(text)
  end
end
