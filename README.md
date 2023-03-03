# kemal-ride

Shard that helps structure [Kemal](https://github.com/kemalcr/kemal) projects and reduce boilerplate work required before/during/after development.

For the moment there's a lot of nuance and too many defaults enabled, but it's part of the process. To enjoy this you'll have to _embrace [Sinatra's](https://github.com/sinatra/sinatra) essence/simplicity_.

> Regrets, I've had a few
>
> But then again too few to mention
>
> I did what I had to do

## Installation

You'll need Crystal and Yarn installed locally, also Redis & Postgres services to start. You can always disable features you don't want/need.

1. Initialize a new crystal app

  ```crystal
  crystal init app app_name
  cd app_name
  ```

2. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     kemal-ride:
       github: fdocr/kemal-ride
   ```

3. Run `shards install`

4. Rename `src/app_name.cr` file as `src/sam.cr` and replace the contents with the following code:

  ```crystal
  require "dotenv"
  Dotenv.load

  require "sam"
  require "kemal-ride"
  require "../lib/kemal-ride/src/kemal-ride/sam.cr"

  Sam.help
  ```

5. Run the following commands to create & initialize the project structure

  ```crystal
  # Create directory structure & add default files
  crystal src/sam.cr kemal:ride

  # Gotta yarn before starting up
  yarn

  # Start your local development server
  make sam kemal:dev
  ```

## Usage

TODO: Write usage instructions here

```bash
# Start local development environment
make sam kemal:dev

# Run specs
make sam kemal:test
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/kemal-ride/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Fernando Valverde](https://github.com/your-github-user) - creator and maintainer
