module ApiHelper
  include ActionView::Helpers::DateHelper
  include GravatarImageTag

  class SmartHTML < Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants
  end

  MARKDOWN_RENDERER = Redcarpet::Markdown.new(SmartHTML.new(:hard_wrap => true), {
    :autolink => true
  })

  def profile_image(email, options={})
    gravatar_image_url(email, { :size => 50, :default => 'identicon' }.merge(options))
  end

  def markdown(text)
    return '' if text.blank?
    MARKDOWN_RENDERER.render(text)
  end
end
