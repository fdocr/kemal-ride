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
  # `ApplicationHandler`). Examples with and without a resource:
  # 
  # ```crystal
  # # src/policies/home_policy.cr
  # 
  # class ChartPolicy < Kemal::Ride::Policy
  #   def index
  #     # Must be authenticated
  #     raise Kemal::Ride::PolicyException.new if signed_out?
  #   end
  #
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
  # class ChartsHandler
  #   get "/charts", &method(:index)
  #   get "/charts/:id", &method(:show)
  #
  #   def index
  #     policy! &.guard do
  #       # policy authorization failed (raised exception)
  #       redirect_to "/"
  #       return # You must return to avoid execution outside the block
  #     end
  #
  #     charts = Charts.all
  #     view
  #   end
  #
  #   def show
  #     chart = Chart.find_by({ :id => params.url["id"] })
  #     policy! &.guard(chart) do
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