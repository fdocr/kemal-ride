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
  # policy classes you have access to Handler auth helper methods because
  # polcies delegates to handlers (requires `auth_helpers` on
  # `ApplicationHandler`). Example:
  # 
  # ```crystal
  # # src/policies/charts_policy.cr
  # 
  # class ChartsPolicy < Kemal::Ride::Policy
  #   def show(resource : Chart = nil)
  #     # Must be authenticated
  #     raise Kemal::Ride::PolicyException.new if signed_out?
  #
  #     if chart = resource
  #       # current_user must own the chart
  #       raise Kemal::Ride::PolicyException.new unless current_user!.id == chart.user_id
  #     else
  #       # Chart not found
  #       raise Kemal::Ride::PolicyException.new
  #     end
  #   end
  # end
  # ```
  # 
  # You can now authorize policies from handlers using the `policy!` and
  # `guard` helper methods.
  # 
  # ```crystal
  # src/handlers/charts_handler.cr
  # 
  # class ChartsHandler
  #   get "/charts", &method(:index)
  #   get "/charts/:id", &method(:show)
  #
  #   def index
  #     # macro to redirect unauthenticated users (optional path param)
  #     redirect_unauthenticated!
  #
  #     charts = Charts.all
  #     view
  #   end
  #
  #   def show
  #     chart = Chart.find_by({ :id => params.url["id"] })
  # 
  #     # Use ChartsPolicy#show policy with `chart` param
  #     policy! &.guard(:show, chart) do
  #       # policy authorization failed (raised exception)
  #       redirect_to "/"
  #       return # You must return to avoid execution outside the block
  #     end
  #
  #     # Policy didn't fail
  #     view
  #   end
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

        def guard_\{{ method.name.id }}(resource)
          begin
            \{{ method.name.id }}(resource)
          rescue Kemal::Ride::PolicyException
            yield
          end
        end
      end

      macro finished
        # Will yield to block if guard is not met. In this case checks user is
        # authenticated.
        def guard_authenticated
          yield if signed_out?
        end

        # Will yield to block if guard is not met. In this case checks user is
        # authenticated.
        def guard_unauthenticated
          yield if signed_in?
        end

        # Likely the main method to use for checking policies. Insipired by the
        # Swift's guard statement
        # (https://docs.swift.org/swift-book/documentation/the-swift-programming-language/statements/#Guard-Statement)
        # it will yield to the block when the policy associated with the 
        # _method_ parameter (Symbol). Example:
        # 
        # ```crystal
        # # Handler method routed to `:update`
        # 
        # def update
        #   policy! &.guard(:update) do
        #     flash.error = "Your access has been revoked. Contact <help@email.com> for assistance"
        #     redirect_to "/page/error"
        #     return
        #   end
        # 
        #   # Business logic...
        # end
        # ```
        # 
        # An alternative for simple redirects are the macros available to
        # Handlers, i.e. `redirect_authenticated!` and
        # `redirect_unauthenticated!` (both accept an optional path parameter
        # to customize the redirect path).
        def guard(method)
          {% begin %}
            begin
              case method
              \{% for method in @type.methods.map(&.name).reject { |name| name.starts_with?("guard_") } %}
                when :\{{ method.id }}
                  guard_\{{ method.id }} { yield }
              \{% end %}
              end
            rescue Kemal::Ride::PolicyException
              yield
            end
          {% end %}
        end

        # Same as `guard` but accepts a _resource_ to pass into the policy
        def guard(method, resource)
          {% begin %}
            begin
              case method
              \{% for method in @type.methods.map(&.name).reject { |name| name.starts_with?("guard_") } %}
                when :\{{ method.id }}
                  guard_\{{ method.id }}(resource) { yield }
              \{% end %}
              end
            rescue Kemal::Ride::PolicyException
              yield
            end
          {% end %}
        end
      end
    end
  end
end