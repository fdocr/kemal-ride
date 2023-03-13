require "dotenv"
Dotenv.load if File.exists?(".env")

require "kemal"
require "kemal-ride"

require "./initializers/kemal"
require "./helpers/**"
require "./models/**"
require "./mailers/**"
require "./policies/**"
require "./jobs/**"

# Require route handlers here:
require "./handlers/root"

Kemal.run