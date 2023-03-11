# Instantiates `Kemal::Ride::AuthPolicy` policy and calls the *method* on it.
# It will redirect to *path* if raises `Kemal::Ride::PolicyException`
# (forbidden access).
macro kemal_auth_policy(method, path)
  begin
    Kemal::Ride::AuthPolicy.new(env).{{ method.id }}
  rescue Kemal::Ride::PolicyException
    env.redirect "{{ path.id }}"
    next
  end
end

# Instantiates a policy *klass* and calls the *method* on it. It will redirect
# to *path* if raises `Kemal::Ride::PolicyException` (forbidden access).
macro kemal_policy(klass, method, path)
  begin
    {{ klass.id }}.new(env).{{ method.id }}
  rescue Kemal::Ride::PolicyException
    env.redirect "{{ path.id }}"
    next
  end
end

# Returns the current user of type `( User | Nil )`
macro kemal_auth_current_user
  Kemal::Ride::Auth.new(env).current_user
end

# Returns the current user of type `User` but it will raise an exception if
# the current user isn't available (unauthenticated session)
macro kemal_auth_current_user!
  Kemal::Ride::Auth.new(env).current_user!
end

# Persists in the current session the `user.id`, in other words "signs in" the
# `user` (variable must be avaiable in route handler).
macro kemal_auth_login_user!
  Kemal::Ride::Auth.new(env).login!(user.id.as(Int64))
end

# Clears the current session, in other words "signs out" the current user
# (if any)
macro kemal_auth_logout_user!
  Kemal::Ride::Auth.new(env).logout!
end

module Kemal::Ride
  # Exception raised when a policy isn't met (forbidden access)
  class PolicyException < Exception
    def initialize
      @message = "Unauthorized"
    end
  end

  # Base Policy class for all custom policies to inherit from. From inside of
  # policy classes you have access to `Kemal::Ride::Auth` instance methods
  # because polcies delegates to it. Example:
  # 
  # ```crystal
  # # src/policies/home_policy.cr
  # 
  # class HomePolicy < Kemal::Ride::Policy
  #   def dashboard!
  #     raise Kemal::Ride::PolicyException.new if signed_out?
  #   end
  # end
  # ```
  # 
  # You can now use the available macros on routes to validate against that
  # custo policy. The following example calls `kemal_policy` macro to execute
  # `HomePolicy#dashboard!`. It will redirect to "/auth/login" if the policy 
  # raises a `Kemal::Ride::PolicyException`.
  # 
  # ```crystal
  # get "/dashboard" do |env|
  #   kemal_policy(HomePolicy, :dashboard!, "/auth/login")
  #   view(:dashboard)
  # end
  # ```
  abstract class Policy
    delegate current_user!, to: @auth
    delegate current_user, to: @auth
    delegate signed_in?, to: @auth
    delegate signed_out?, to: @auth

    def initialize(@env : HTTP::Server::Context)
      @auth = Kemal::Ride::Auth.new(@env)
    end
  end

  # Base Authentication policy used for common scenarios, like to check if a
  # user is signed in or not. To use this policy within route handlers it will
  # likely be better to rely on the existing macro `kemal_auth_policy`
  class AuthPolicy < Policy
    # Raises `Kemal::Ride::PolicyException` if user is signed out (isn't
    # _unauthenticated_)
    def authenticated!
      raise Kemal::Ride::PolicyException.new if signed_out?
    end

    # Raises `Kemal::Ride::PolicyException` if user is signed in (isn't
    # _unauthenticated_)
    def unauthenticated!
      raise Kemal::Ride::PolicyException.new if signed_in?
    end
  end

  # Main point of entry to standardize access to the user associated with the
  # session, as well as other utility methods. Examples:
  # 
  # ```crystal
  # Kemal::Ride::Auth.new(env).current_user!
  # Kemal::Ride::Auth.new(env).login!(user.id)
  # Kemal::Ride::Auth.new(env).logout!
  # ```
  # 
  # Within route handlers it might be useful to rely on macros like 
  # `kemal_auth_current_user`, `kemal_auth_current_user!`, 
  # `kemal_auth_login_user!`, 
  class Auth
    def initialize(@env : HTTP::Server::Context); end

    def current_user!
      User.find!(@env.session.bigint("uid"))
    end

    def current_user
      if uid = @env.session.bigint?("uid")
        User.find!(uid)
      end
    end

    def signed_in?
      !signed_out?
    end

    def signed_out?
      @env.session.bigint?("uid").nil?
    end

    def login!(user_id : Int64)
      @env.session.bigint("uid", user_id)
    end

    def logout!
      @env.session.destroy
    end
  end
end