class HomeHandler < ApplicationHandler
  # Render view
  get "/", &render_view(:index)

  # Execute method
  # get "/", &method(:index)
  
  # def index
  #   puts "Check the console..."
  #   view
  # end
end