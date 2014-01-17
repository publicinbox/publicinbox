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
      date, id = File.basename(file, '.md').match(Post::FILENAME_PATTERN)[1, 2]

      date = Date.parse(date)
      title = id.gsub('-', ' ').humanize

      post = Post.new(id, date, title)

      map[post.id] = post
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
