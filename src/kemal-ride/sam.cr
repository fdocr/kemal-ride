require "sentry"

def webpack_up
  app_env = "NODE_ENV=#{ENV["KEMAL_ENV"]? || "development"}"
  "#{app_env} yarn run build && #{app_env} yarn run build:css"
end

task "webpack" do
  system webpack_up
end

# Sam.namespace "g" do
  
# end

Sam.namespace "kemal" do
  # TODO: Make this portable across platforms by replacing the `cp` calls
  # TODO: Make this configurable (opt-out to DB/telemetry/webpack/etc)
  task "ride" do |_, args|
    Log.info { "Copying files..." }

    lib_prefix = "lib/kemal-ride/src/kemal-ride/templates"

    # App-level files
    Dir.mkdir_p("src/initializers")
    File.copy("#{lib_prefix}/initializers/database.cr", "src/initializers/database.cr")
    File.copy("#{lib_prefix}/initializers/kemal.cr", "src/initializers/kemal.cr")
    File.copy("#{lib_prefix}/initializers/logger.cr", "src/initializers/logger.cr")
    File.copy("#{lib_prefix}/initializers/mailer.cr", "src/initializers/mailer.cr")
    File.copy("#{lib_prefix}/initializers/mosquito.cr", "src/initializers/mosquito.cr")
    File.copy("#{lib_prefix}/initializers/open_telemetry.cr", "src/initializers/open_telemetry.cr")

    Dir.mkdir_p("src/handlers")
    File.copy("#{lib_prefix}/handlers/application_handler.cr", "src/handlers/application_handler.cr")
    File.copy("#{lib_prefix}/handlers/home_handler.cr", "src/handlers/home_handler.cr")

    Dir.mkdir_p("src/mailers")
    File.copy("#{lib_prefix}/mailers/application_mailer.cr", "src/mailers/application_mailer.cr")

    Dir.mkdir_p("src/models")
    File.copy("#{lib_prefix}/models/application_record.cr", "src/models/application_record.cr")

    Dir.mkdir_p("src/views/home")
    Dir.mkdir_p("src/views/shared")
    File.copy("#{lib_prefix}/views/home/index.ecr", "src/views/home/index.ecr")
    File.copy("#{lib_prefix}/views/shared/layout.ecr", "src/views/shared/layout.ecr")

    Dir.mkdir_p("src/webpack/controllers")
    Dir.mkdir_p("src/webpack/stylesheets")
    File.copy("#{lib_prefix}/webpack/app.js", "src/webpack/app.js")
    File.copy("#{lib_prefix}/webpack/controllers/hello_controller.js", "src/webpack/controllers/hello_controller.js")
    File.copy("#{lib_prefix}/webpack/stylesheets/app.css", "src/webpack/stylesheets/app.css")

    Dir.mkdir_p("src/jobs")
    File.copy("#{lib_prefix}/jobs/application_job.cr", "src/jobs/application_job.cr")

    Dir.mkdir_p("src/helpers")
    File.copy("#{lib_prefix}/helpers/.keep", "src/helpers/.keep")

    Dir.mkdir_p("src/policies")
    File.copy("#{lib_prefix}/policies/.keep", "src/policies/.keep")
    
    File.copy("#{lib_prefix}/sam.cr", "src/sam.cr")
    File.copy("#{lib_prefix}/app.cr", "src/app.cr")
    File.copy("#{lib_prefix}/worker.cr", "src/worker.cr")
    File.copy("#{lib_prefix}/bundle.cr", "src/bundle.cr")
    File.copy("#{lib_prefix}/sample.env", ".env")
    File.copy("#{lib_prefix}/Makefile", "Makefile")
    File.copy("#{lib_prefix}/Dockerfile", "Dockerfile")
    File.copy("#{lib_prefix}/package.json", "package.json")
    File.copy("#{lib_prefix}/webpack.config.js", "webpack.config.js")
    File.copy("#{lib_prefix}/tailwind.config.js", "tailwind.config.js")

    # Migrations
    Dir.mkdir_p("db/migrations")
    # Static files
    Dir.mkdir_p("public/assets")
    File.copy("#{lib_prefix}/public/assets/favicon.ico", "public/assets/favicon.ico")

    # Append to .gitignore
    ignore_append = <<-IGNORE

    # kemal-ride ignores
    node_modules/
    public/app.js
    public/app.css
    .env
    app
    worker
    bundle
    yarn-error.log
    IGNORE
    File.write(".gitignore", ignore_append, mode: "a")

    Log.info { "Running yarn install" }
    system "yarn install"

    Log.info { "Done! Start your local development with `make sam kemal:dev`" }
  end

  task "auth" do
    Log.info { "Copying files..." }

    lib_prefix = "lib/kemal-ride/src/kemal-ride/templates"
    Dir.mkdir_p("db/migrations")
    filename = "db/migrations/#{Time.local.to_unix_ms}_create_user.cr"
    File.copy("#{lib_prefix}/db/migrations/create_user.cr", filename)

    File.copy("#{lib_prefix}/models/user.cr", "src/models/user.cr")

    Dir.mkdir_p("src/views/auth/register")
    Dir.mkdir_p("src/views/auth/session")
    Dir.mkdir_p("src/views/auth/reset")
    File.copy("#{lib_prefix}/views/auth/register/new.ecr", "src/views/auth/register/new.ecr")
    File.copy("#{lib_prefix}/views/auth/reset/reset.ecr", "src/views/auth/reset/reset.ecr")
    File.copy("#{lib_prefix}/views/auth/session/new.ecr", "src/views/auth/session/new.ecr")
    File.copy("#{lib_prefix}/views/auth/session/logout.ecr", "src/views/auth/session/logout.ecr")

    Dir.mkdir_p("src/handlers/auth")
    File.copy("#{lib_prefix}/handlers/auth/register_handler.cr", "src/handlers/auth/register_handler.cr")
    File.copy("#{lib_prefix}/handlers/auth/reset_handler.cr", "src/handlers/auth/reset_handler.cr")
    File.copy("#{lib_prefix}/handlers/auth/session_handler.cr", "src/handlers/auth/session_handler.cr")

    Log.info do
      <<-NEXT_STEPS
        Done! Now:
        - `src/handlers/application_handler.cr` uncomment `auth_helpers` macro call
        - `src/handlers/application_handler.cr` also uncomment `require "./auth/**"`
        - `src/sam.cr` uncomment DB related lines
        
        Great! You can now:
        - Create DB & run migrations `make sam db:setup`
        - Continue your way with `make sam kemal:dev`
      NEXT_STEPS
    end
  end

  task "dev" do
    build_command = "crystal build ./src/app.cr"
    run_command = ""

    if Dir.new("src/webpack").children.size > 0
      # There's stuff in `src/webpack/` dir
      app_env = "NODE_ENV=#{ENV["KEMAL_ENV"]? || "development"}"
      build_command = <<-BUILD
        #{app_env} yarn run build &&
        #{app_env} yarn run build:css &&
        crystal build ./src/app.cr
        BUILD
    end

    if File.exists?("./src/worker.cr")
      # Compile bundle once (doesn't need to re-compile each time)
      # system "crystal build ./src/bundle.cr"

      # Modify run/build command
      run_command = "./bundle"
      if build_command.empty?
        build_command = <<-BUILD
          crystal build ./src/app.cr
          crystal build ./src/worker.cr
          crystal build ./src/bundle.cr
          BUILD
      else
        build_command = <<-BUILD
          #{build_command}
          crystal build ./src/worker.cr
          crystal build ./src/bundle.cr
          BUILD
      end
    end

    run_command = "./app" if run_command.blank?

    Sentry::ProcessRunner.new(
      display_name: "Kemal::Ride",
      build_command: build_command,
      run_command: run_command,
      files: [ "./src/**/*" ]
    ).run
  end

  task "test" do
    res = system "KEMAL_ENV=test crystal spec"
    raise "Tests failed!" unless res
  end
end

Sam.help