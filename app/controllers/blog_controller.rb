class BlogController < ApplicationController
  def index
    @posts = Blog.posts
  end

  def show
    post   = Blog.post(params[:permalink])
    @title = post.title
    @date  = post.date

    render(:action => post.action)
  end
end
