require "./kemal-ride/log_handler"
require "./kemal-ride/application_job"

macro view(filename = nil, layout = true, path = "src/views", folder = __FILE__)
  {% if !filename %}
    raise "Filename required!"
  {% end %}

  {{ short_path = folder.gsub(/^.+?src\/routes\//, "").gsub(/\.cr$/, "") }}

  {% if layout %}
    {% if layout.class_name == "StringLiteral" %}
      render "src/views/#{{{short_path}}}/{{filename.id}}.ecr", "src/views/shared/{{layout.id}}.ecr"
    {% else %}
      render "src/views/#{{{short_path}}}/{{filename.id}}.ecr", "src/views/shared/layout.ecr"
    {% end %}
  {% else %}
    render "src/views/#{{{short_path}}}/{{filename.id}}.ecr"
  {% end %}
end

# Module that wraps some helper methods, classes, and includes macros useful
# to structure a Kemal project. It leverages `imdrasil/sam.cr` shard as a task
# runner tool to automate a few different aspects of the development experience
module Kemal::Ride
  VERSION = "0.1.2"

  @@log_severity : Log::Severity? = nil

  def self.log_level
    return @@log_severity.as(Log::Severity) unless @@log_severity.nil?

    log_level = Log::Severity::Info
    if ENV["LOG_LEVEL"]?.presence
      case ENV["LOG_LEVEL"]
      when "TRACE"
        log_level = Log::Severity::Trace
      when "DEBUG"
        log_level = Log::Severity::Debug
      when "INFO"
        log_level = Log::Severity::Info
      when "NOTICE"
        log_level = Log::Severity::Notice
      when "WARN"
        log_level = Log::Severity::Warn
      when "ERROR"
        log_level = Log::Severity::Error
      when "FATAL"
        log_level = Log::Severity::Fatal
      when "NONE"
        log_level = Log::Severity::None
      end
    elsif Kemal.config.env == "production"
      log_level = Log::Severity::Error
    end

    @@log_severity = log_level
    @@log_severity.as(Log::Severity)
  end
end
