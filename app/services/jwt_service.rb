class JwtService
  HMAC_SECRET = Rails.application.credentials.secret_key_base
  EXPIRATION_TIME = 24.hours.from_now

  def self.encode(payload)
    payload = payload.dup
    payload[:exp] = EXPIRATION_TIME.to_i
    JWT.encode(payload, HMAC_SECRET, 'HS256')
  end

  def self.decode(token)
    body = JWT.decode(token, HMAC_SECRET, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end