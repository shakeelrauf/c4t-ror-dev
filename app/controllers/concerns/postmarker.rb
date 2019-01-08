# Use the 'postmark' gem to send the email
module Postmarker extend ActiveSupport::Concern

# A simpler error sender
  def send_error(subject, content="")
    # The exception message
    if ($!.present?)
      content += "Exception message: #{$!} <br>"
      content += "<br>"
      subject += " #{$!}"
    end
    # The stack trace
    if ($@.present?)
      $@.each do |i|
        content += "#{i}<br>"
      end
    end
    from = ENV['ERROR_FROM']
    recipient = ENV['ERROR_RECIPIENT']
    if ENV['EMAIL_ASYNC']
      j = Job::Postmarker.create(to: recipient, content: content, subject: subject, from: from)
      j.queued?
      j.save!
    else
      token = ENV['POSTMARK_API_TOKEN_ERROR']
      puts "===========> Error from,rec: #{from},#{recipient}"
      return if (recipient.blank? || token.blank? || from.blank?)
      client = Postmark::ApiClient.new(token)
      client.deliver(from: from,
                     to: recipient,
                     subject: subject,
                     html_body: content)
    end
  end

  def send_email_domain(subject, content, to, attachments=[])
    send_email(subject, content, to, attachments)
  end

  def send_email(subject, content, to, attachments=[])
    from = "support@aflsix.com"
    client = Postmark::ApiClient.new(ENV['POSTMARK_API_TOKEN_COM'])
    client.deliver(from: from,
                   to: to,
                   subject: subject,
                   html_body: content)
  end

  # Used by the task controller

end
