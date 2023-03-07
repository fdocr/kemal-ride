require "sentry"

def webpack_up
  app_env = "NODE_ENV=#{ENV["KEMAL_ENV"]? || "development"}"
  "#{app_env} yarn run build && #{app_env} yarn run build:css"
end

task "webpack" do
  system webpack_up
end

Sam.namespace "kemal" do
  # TODO: Make this portable across platforms by replacing the `cp` calls
  # TODO: Make this configurable (opt-out to DB/telemetry/webpack/etc)
  task "ride" do |_, args|
    p "Copying files..."

    lib_prefix = "lib/kemal-ride/src/kemal-ride/templates"
    [
      "initializers", "mailers", "models", "routes", 
      "views", "webpack", "jobs", "helpers"
    ].each do |dirname|
      system "cp -R #{lib_prefix}/#{dirname} src/"
    end

    # App-level files
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
    Dir.mkdir_p("public")
    File.copy("#{lib_prefix}/public/favicon.ico", "public/favicon.ico")

    # Append to .gitignore
    ignore_append = <<-IGNORE

    # kemal-ride ignores
    node_modules/
    public/app.js
    public/app.css
    .env
    app
    worker
    yarn-error.log
    IGNORE
    File.write(".gitignore", ignore_append, mode: "a")

    p "Running yarn install"
    system "yarn install"

    p "Done! Start your local development with `make sam kemal:dev`"
  end

  task "dev" do
    sentry = [] of Sentry::ProcessRunner
    if Dir.new("src/webpack").children.size > 0
      # There's stuff in `src/webpack/` dir
      app_env = "NODE_ENV=#{ENV["KEMAL_ENV"]? || "development"}"
      sentry << Sentry::ProcessRunner.new(
        display_name: "Webpack",
        build_command: "#{app_env} yarn run build && #{app_env} yarn run build:css && crystal build ./src/app.cr",
        run_command: "./app",
        files: [ "./src/**/*" ]
      )
    else
      sentry << Sentry::ProcessRunner.new(
        display_name: "App",
        build_command: "crystal build ./src/app.cr",
        run_command: "./app",
        run_args: ["-p", "8080"],
        files: [ "./src/**/*" ]
      )
    end

    if File.exists?("./src/worker.cr")
      sentry << Sentry::ProcessRunner.new(
        display_name: "Worker",
        build_command: "crystal build ./src/worker.cr",
        run_command: "./worker",
        files: [ "./src/**/*" ]
      )
    end

    # Execute runners in separate threads
    sentry.each { |s| spawn { s.run } }

    begin
      sleep
    rescue
      sentry.each(&.kill)
    end
  end

  task "test" do
    res = system "KEMAL_ENV=test crystal spec"
    raise "Tests failed!" unless res
  end
end

Sam.help