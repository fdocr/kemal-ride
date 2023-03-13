class Auth::ResetHandler < ApplicationHandler
  BASE = "/auth/reset"
  get BASE, &method(:reset)
  post BASE, &method(:update)
  
  def reset
    redirect_authenticated!
    user = User.build_empty
    view(:reset)
  end

  def update
    redirect_authenticated!
    user = User.build_from(params.body)
    if user.save
      redirect_to "/"
    else
      view(:reset)
    end
  end
end