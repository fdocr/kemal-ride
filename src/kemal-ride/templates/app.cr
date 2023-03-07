require "dotenv"
Dotenv.load if File.exists?(".env")

require "kemal"
require "kemal-ride"

require "./initializers/kemal"
require "./helpers/**"
require "./models/**"
require "./mailers/**"
require "./jobs/**"

# Require all routes here
require "./routes/home"

Kemal.run