class Rack::Attack
throttle("comments/ip", limit: 20, period: 1.minute) do |request|
  if request.path == "/comments" && request.post?
    request.ip
  end
end

throttle("comments/per_post", limit: 5, period: 1.minute) do |request|
  next unless request.path == "/comments"
  next unless request.post?

  key = "#{request.ip}:#{request.params['post_id']}"

  key
end

  throttle("likes/ip", limit: 60, period: 1.minute) do |request|
    if request.path == "/likes" && request.post?
      request.ip
    end
  end

  throttle("logins/ip", limit: 5, period: 1.minute) do |request|
    if request.path == "/users/sign_in" && request.post?
      request.ip
    end
  end

  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    retry_after = match_data[:period]

    message =
      case request.path
      when "/users/search"
        "Too many search requests. Please wait a moment and try again."
      when "/users/sign_in"
        "Too many login attempts. Please try again in a minute."
      when "/comments"
        "Too many comments. Please slow down and try again."
      when "/likes"
        "Too many likes. Please slow down and try again."
      else
        "Too many requests. Please slow down and try again later."
      end

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [
        {
          error: message
        }.to_json
      ]
    ]
  end
end
