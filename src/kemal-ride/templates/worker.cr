require "dotenv"
Dotenv.load if File.exists?(".env")

require "./initializers/kemal"
require "./models/**"
require "./jobs/**"

Mosquito::Runner.start