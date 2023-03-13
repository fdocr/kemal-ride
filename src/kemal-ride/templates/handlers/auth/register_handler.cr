class Auth::RegisterHandler < ApplicationHandler
  BASE = "/auth/register"
  get BASE, &method(:new)
  post BASE, &method(:create)
  
  def new
    redirect_authenticated!
    user = User.build_empty
    view(:new)
  end

  def create
    redirect_authenticated!
    user = User.build_from(params.body)
    if user.save
      redirect_to "/"
    else
      view(:new)
    end
  end
end