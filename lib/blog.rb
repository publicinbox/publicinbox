class Blog
  POSTS_DIR = File.join(Rails.root, 'app', 'views', 'blog')

  class Post
    FILENAME_PATTERN = /^(\d{4}-\d{2}-\d{2})-(.*)$/

    attr_reader :id, :date, :title

    def initialize(id, date, title)
      @id = id
      @date = date
      @title = title
    end
  end

  @@posts = nil

  def self.load_all_posts!
    @@posts ||= Dir[File.join(POSTS_DIR, '*.md')].inject({}) do |map, file|
      id, date, title = File.basename(file, '.md').match(Post::FILENAME_PATTERN)[0..2]

      # Make the date an actual date so we can format it
      date = Date.parse(date)

      # Make the title not hideous
      title = title.gsub('-', ' ').humanize

      # Index posts by id
      map[id] = Post.new(id, date, title)
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
