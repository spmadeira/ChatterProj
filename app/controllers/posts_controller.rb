class PostsController < ApplicationController
  include CableReady::Broadcaster
  before_action :authenticate_user!

  def index
    puts user_signed_in?
    @posts = Post.all.order(created_at: :desc)
    @post = Post.new
  end

  def create
    post = Post.create(post_params)
    post.update!(username: current_user.email)
    cable_ready["timeline"].insert_adjacent_html(
      selector: "#timeline",
      position: "afterbegin",
      html: render_to_string(partial: "post", locals: {post: post})
    )
    cable_ready.broadcast
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:body)
  end
end
