require "carbon"

abstract class ApplicationMailer < Carbon::Email
  getter email_subject : String, email_address : String

  from Carbon::Address.new("<app name>", "example@email.com")
  to email_address
  subject email_subject
  settings.adapter = MAILER_ADAPTER

  def initialize
    @email_address = ""
    @email_subject = ""
  end
end
