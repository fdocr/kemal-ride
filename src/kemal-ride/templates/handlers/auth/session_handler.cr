class Auth::SessionHandler < ApplicationHandler
  get "/auth/login", &method(:new)
  post "/auth/login", &method(:create)

  get "/auth/logout", &method(:logout)
  post "/auth/logout", &method(:destroy)

  def new
    redirect_authenticated!
    error_message = ""
    view(:new)
  end

  def create
    redirect_authenticated!
    error_message = ""
    user = User.find_by!({ :email => params.body["email"].as(String) })

    if user.authenticate(params.body["password"].as(String))
      login!(user.id.to_s)
      redirect_to "/"
    else
      error_message = "Invalid credentials"
      view(:new)
    end
  rescue Jennifer::RecordNotFound
    # Handling user not found the same as bad password
    error_message = "Invalid credentials"
    view(:new)
  end

  def logout
    redirect_unauthenticated!
    view(:logout)
  end

  def destroy
    redirect_unauthenticated!
    logout!
    redirect_to "/"
  end
end