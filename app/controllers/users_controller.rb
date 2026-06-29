class UsersController < ApplicationController
  def index
    @q = User.ransack(params[:q])

    users_scope = @q.result(distinct: true)
                    .includes(avatar_attachment: :blob)
                    .where.not(id: current_user.id)
                    .order(:username)

                    @show_all_users = users_scope.limit(6).size > 5

                    @users =
                      if params[:show] == "users"
                        users_scope
                      else
                        users_scope.limit(5)
                      end

    @posts = []
    @show_all_posts = false

    if params.dig(:q, :username_or_first_name_or_last_name_cont).present?
      query = params[:q][:username_or_first_name_or_last_name_cont].strip

      posts_scope = Post
        .joins(:user)
        .includes(
          { user: { avatar_attachment: :blob } },
          images_attachments: :blob
        )
        .where(
          <<~SQL,
            posts.content LIKE :q
            OR users.username LIKE :q
            OR users.first_name LIKE :q
            OR users.last_name LIKE :q
            OR CONCAT(users.first_name, ' ', users.last_name) LIKE :q
          SQL
          q: "%#{query}%"
        )
        .order(created_at: :desc)

        @show_all_posts = posts_scope.limit(6).size > 5

        @posts =
          if params[:show] == "posts"
            posts_scope
          else
            posts_scope.limit(5)
          end
    end
  end

  def search
    query = params[:query].to_s.strip

    @users = User
      .includes(avatar_attachment: :blob)
      .where.not(id: current_user.id)
      .where(
        <<~SQL,
          username LIKE :q
          OR first_name LIKE :q
          OR last_name LIKE :q
          OR CONCAT(first_name, ' ', last_name) LIKE :q
        SQL
        q: "%#{query}%"
      )
      .order(:username)
      .limit(5)

    render partial: "users/search_results"
  end
end
