# Macro to call from `src/handlers/application_handler.cr` to use auth
# helpers like `current_user`, `signed_in?`, etc
macro auth_helpers
  property current_user : User?

  def current_user
    return @current_user unless @current_user.nil?
    @current_user = if uid = session.string?("uid")
      User.find(uid)
    end
  end

  def current_user!
    User.find!(session.string("uid"))
  end

  def signed_in?
    !signed_out?
  end

  def signed_out?
    session.string?("uid").nil?
  end

  def login!(user_id : String)
    session.string("uid", user_id)
  end

  def logout!
    session.destroy
  end
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
  # because polcies delegates to handlers (requires `auth_helpers` on 
  # `ApplicationHandler`). Example:
  # 
  # ```crystal
  # # src/policies/home_policy.cr
  # 
  # class HomePolicy < Kemal::Ride::Policy
  #   def dashboard
  #     raise Kemal::Ride::PolicyException.new if signed_out?
  #   end
  # end
  # ```
  # 
  # You can now authorize policies from handlers this way:
  # 
  # ```crystal
  # get "/dashboard" do |env|
  #   policy! &.guard_dashboard do
  #     # policy authorization failed (raised exception)
  #     redirect_to "/"
  #     return # You must return to avoid execution outside the block
  #   end
  # 
  #   # Policy didn't fail
  #   view(:dashboard)
  # end
  # ```
  abstract class Policy
    delegate current_user!, to: @handler
    delegate current_user, to: @handler
    delegate signed_in?, to: @handler
    delegate signed_out?, to: @handler

    getter handler : Kemal::Ride::BaseHandler

    def initialize(@handler); end

    macro inherited
      macro method_added(method)
        def guard_\{{ method.name.id }}
          begin
            \{{ method.name.id }}
          rescue Kemal::Ride::PolicyException
            yield
          end
        end
      end
    end
  end

  # Base Authentication policy used for common scenarios, like to check if a
  # user is signed in or not. Handlers support helper methods like
  # `Kemal::Ride::BaseHandler#authenticated!` or
  # `Kemal::Ride::BaseHandler#unauthenticated!`, both of which accept a block
  # which will in turn execute when the default `#authenticated!` and 
  # `#unauthenticated` policies fail (exception raised). Example:
  # 
  # ```crystal
  # get "/dashboard" do |env|
  #   guard_authenticated do
  #     # policy authorization failed (raised exception)
  #     redirect_to "/"
  #     return # You must return to avoid execution outside the block
  #   end
  # 
  #   # Policy didn't fail
  #   view(:dashboard)
  # end
  # ```
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
end