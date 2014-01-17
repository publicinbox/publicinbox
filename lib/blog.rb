class Blog
  POSTS_DIR = File.join(Rails.root, 'app', 'views', 'blog')

  class Post
    FILENAME_PATTERN = /^(\d{4}-\d{2}-\d{2})-(.*)$/

    attr_reader :permalink, :date, :title, :action

    def initialize(permalink, date, title)
      @permalink = permalink
      @date = date
      @title = title
      @action = permalink.gsub('/', '-')
    end
  end

  @@posts = nil

  def self.load_all_posts!
    @@posts ||= Dir[File.join(POSTS_DIR, '*.md')].inject({}) do |map, file|
      date, title = File.basename(file, '.md').match(Post::FILENAME_PATTERN)[1, 2]

      # Make the date an actual date so we can format it
      date = Date.parse(date)

      # Make the permalink look like yyyy/mm/dd/title-of-post
      permalink = "#{date.strftime('%Y/%m/%d')}/#{title}"

      # Make the title not hideous
      title = title.gsub('-', ' ').humanize

      # Index posts by permalink
      map[permalink] = Post.new(permalink, date, title)
      map
    end
  end

  def self.posts
    self.load_all_posts!
    @@posts.values
  end

  def self.post(id)
    self.load_all_posts!
    @@posts[id]
  end
end
