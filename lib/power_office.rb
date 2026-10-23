require "json"
require "net/http"
require "openssl"
require "uri"

require_relative "power_office/version"
require_relative "power_office/configuration"
require_relative "power_office/errors"
require_relative "power_office/response"
require_relative "power_office/request"
require_relative "power_office/connection"
require_relative "power_office/access_token"
require_relative "power_office/authenticator"
require_relative "power_office/resource"
require_relative "power_office/retrievable"
require_relative "power_office/resources"
require_relative "power_office/onboarding"
require_relative "power_office/client"

# PowerOffice Go API v2 client.
#
# The application and subscription keys belong to SERVOS as the integration
# developer; the client key belongs to the customer's PowerOffice client.
#
# @see https://developer.poweroffice.net/documentation/authentication
# @see https://swagger.poweroffice.net
module PowerOffice
end
