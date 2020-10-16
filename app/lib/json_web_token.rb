class JsonWebToken
	# TODO: how to encrypt it???
  JWT_SECRET_KEY = 'lgeoaordneer'
  
  LAMBDA_SECRET_KEY = 'reendroaoegl'

  def self.encode(payload)
    exp = Time.now.to_i + 1 * 60 * 60
    payload['exp'] = exp
    payload['iat'] = Time.now.to_i
    p payload
    JWT.encode(payload, JWT_SECRET_KEY)
  end

  def self.encode_for_lambda(payload)
    JWT.encode(payload, LAMBDA_SECRET_KEY)
  end

  def self.decode(token)
    return HashWithIndifferentAccess.new(JWT.decode(token, JWT_SECRET_KEY)[0])
  rescue
    nil
  end
end
