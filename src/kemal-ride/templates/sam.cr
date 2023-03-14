require "dotenv"
Dotenv.load

require "sam"
require "kemal-ride"
# Uncomment for DB use
#require "./initializers/database"
#require "../db/migrations/*"
#require "../lib/jennifer/src/jennifer/sam"
require "../lib/kemal-ride/src/kemal-ride/sam"

Sam.help