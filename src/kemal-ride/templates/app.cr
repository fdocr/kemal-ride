require "dotenv"
Dotenv.load if File.exists?(".env")

require "kemal"
require "kemal-ride"

# require "./initializers/kemal.cr"
require "./initializers/**"
require "./helpers/**"
# require "./models/application_record.cr"
require "./models/**"
# require "../src/mailers/application_mailer.cr"
require "./mailers/**"
require "./jobs/**"
require "./routes/**"

Kemal.run