require "dotenv"
Dotenv.load

require "sam"
require "kemal-ride"
require "../lib/kemal-ride/src/kemal-ride/sam.cr"

require "./initializers/database"
require "../db/migrations/*"
load_dependencies "jennifer"

Sam.help