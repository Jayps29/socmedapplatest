class UsersController < ApplicationController
  def index
    @q = User.ransack(params[:q])

    @pagy, @users = pagy(
      :offset,
      @q.result(distinct: true)
        .where.not(id: current_user.id)
        .order(:username),
      limit: 10
    )
  end

  def search
    @users = User
      .where.not(id: current_user.id)
      .where(
        "username LIKE :q OR first_name LIKE :q OR last_name LIKE :q",
        q: "%#{params[:query]}%"
      )
      .limit(5)

    render partial: "users/search_results"
  end
end
