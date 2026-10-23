module PowerOffice
  class AccessToken < Data.define(:value, :expires_at)
    # Tokens live 20 minutes. Renewing a minute early keeps a token from
    # lapsing while a request is in flight.
    EXPIRY_MARGIN = 60

    def self.from_response(body, now: Time.now)
      new(value: body.fetch("access_token"), expires_at: now + body.fetch("expires_in").to_i)
    end

    def expired?(now: Time.now)
      now >= expires_at - EXPIRY_MARGIN
    end
  end
end
