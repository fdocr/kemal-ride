require "dotenv"
Dotenv.load if File.exists?(".env")

require "./initializers/**"
require "./models/**"
require "./jobs/**"

Mosquito::Runner.start