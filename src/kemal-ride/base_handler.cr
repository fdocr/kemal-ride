class HTTP::Server::Context
  property handler : Kemal::Ride::BaseHandler?
end

module Kemal::Ride
  abstract class BaseHandler
    macro inherited
      setup_policy
    end

    macro setup_policy
      getter context : HTTP::Server::Context

      {% policy_class = @type.stringify.gsub(/Handler$/, "Policy") %}
      {% if @top_level.has_constant?(policy_class) %}
        getter policy : {{ policy_class.id }}?

        def initialize(@context)
          @policy = {{ policy_class.id }}.new(self)
        end
      {% else %}
        def initialize(@context); end
      {% end %}
    end

    delegate :session, :params, :request, to: context

    def self.instance(env : HTTP::Server::Context)
      {% begin %}
      if env.handler.nil?
        env.handler = self.new(env)
      end
      env.handler.as(self)
      {% end %}
    end
  
    def redirect_to(url)
      context.redirect(url)
    end
  
    macro method(m)
      -> (env : HTTP::Server::Context) do
        self.instance(env).{{m.id}}
      end
    end

    macro render(m)
      -> (env : HTTP::Server::Context) do
        self.instance(env)
        view(:{{m.id}})
      end
    end

    def policy!
      if policy = @policy
        yield policy
      end
    end

    macro redirect_authenticated!(path = "/")
      if signed_in?
        redirect_to {{ path }}
        return
      end
    end

    macro redirect_unauthenticated!(path = "/")
      if signed_out?
        redirect_to {{ path }}
        return
      end
    end

    # Misc helpers
    private def redirect_back
      redirect_to request.headers["Referer"]? || root_path
    end

    private def page
      (params.query["page"]? || 0).to_i
    end

    private def t(key, *args, **opts)
      I18n.translate("#{self.class.to_s.underscore}.#{key}", *args, **opts)
    end
  end  
end