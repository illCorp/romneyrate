module DeployMailer
  extend self

  MAILER_OPTIONS = {
    :address              => "smtp.sendgrid.net",
    :port                 => 587,
    :domain               => "meeps.com",
    :user_name            => "mranauro@meeps.com",
    :password             => "Beantown79*",
    :authentication       => :plain,
    :enable_starttls_auto => true  }

  # MAILER_OPTIONS = {
  #    :address              => "smtp.sendgrid.net",
  #    :port                 => 25,
  #    :domain               => "meeps.com",
  #    :user_name            => "mranauro@meeps.com",
  #    :password             => "Beantown79*",
  #    :authentication       => :plain  }

  def options
    MAILER_OPTIONS
  end

  def send_notification(sub, msg, recipients)
    mail = Mail.new do
      to recipients
      from "noreply@meeps.com"
      subject sub
      body msg
    end
    mail.deliver
  end

end
