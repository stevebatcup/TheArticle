require "mandrill"

module MandrillMailer
  MANDRILL_SERVICE_FOR_API_LOG = 'mandrill'

private

  def requires_interception
    if Rails.env.development?
      return true
    else
      return false
    end
  end

  def send_mail(email_address, subject, body)
    if requires_interception
      to = "steve.batcup@gmail.com"
      subject = "#{subject} [for #{email_address}]"
    else
      to = email_address
    end
    data = { to: to, subject: subject, body: body, content_type: "text/html" }
    response = mail(**data)
    # log_mandrill_request(user.id, "send_mail", data, response)
  end

  def send_admin_mail(subject, body)
    data = { to: ENV["ADMIN_EMAIL"], subject: subject, body: body, content_type: "text/html" }
    response = mail(**data)
    # log_mandrill_request(0, "send_admin_mail", data, response)
  end

  def mandrill_template(template_name, attributes)
    mandrill = Mandrill::API.new(Rails.application.credentials.mandrill[:api_key][Rails.env.to_sym])
    merge_vars = attributes.map do |key, value|
      { name: key, content: value }
    end
    mandrill.templates.render(template_name, [], merge_vars)["html"]
  end

  def log_mandrill_request(user_id, method, request_data, response)
    response = response.is_a?(Mail::Message) ? {status: 'success'} : nil
    ApiLog.request(
      user_id: user_id,
      service: MANDRILL_SERVICE_FOR_API_LOG,
      request_method: method,
      request_data: request_data,
      response: response,
    )
  end
end