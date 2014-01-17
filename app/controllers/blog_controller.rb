class BlogController < ApplicationController
  def index
    @posts = Blog.posts
  end

  def show
    post   = Blog.post(params[:id])
    @title = post.title
    @date  = post.date

    render(:action => post.permalink)
  end
end
