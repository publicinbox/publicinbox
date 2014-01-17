# Configure markdown-rails to use Redcarpet w/ SmartyPants
# rather than rdiscount
MarkdownRails.configure do |config|
  class SmartyPantsRenderer < Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants
  end

  markdown = Redcarpet::Markdown.new(SmartyPantsRenderer)

  config.render do |markdown_source|
    markdown.render(markdown_source)
  end
end

Blog.load_all_posts!
