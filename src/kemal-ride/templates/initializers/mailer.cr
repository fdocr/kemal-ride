require "carbon"
require "carbon_smtp_adapter"
require "email_opener/carbon_adapter"

MAILER_ADAPTER =
  if Kemal.config.env == "production"
    Carbon::SmtpAdapter.new
  else
    EmailOpener::CarbonAdapter.new
  end

Carbon::SmtpAdapter.configure do |settings|
  settings.host = ENV["SMTP_HOST"]
  settings.port = 25
  settings.helo_domain = nil
  settings.use_tls = true
  settings.username = ENV["SMTP_PASSWORD"]
  settings.password = ENV["SMTP_USER_NAME"]
end