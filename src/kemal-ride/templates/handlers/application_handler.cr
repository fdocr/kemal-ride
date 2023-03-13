class ApplicationHandler < Kemal::Ride::BaseHandler
  # Reminder: Don't handle routes with the application handler
  # auth_helpers
end

# Require handlers in order
require "./home_handler"