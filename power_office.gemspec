require_relative "lib/power_office/version"

Gem::Specification.new do |spec|
  spec.name = "power_office"
  spec.version = PowerOffice::VERSION
  spec.authors = ["SERVOS"]
  spec.email = ["a@asgerbehnckejacobsen.dk"]

  spec.summary = "Ruby client for the PowerOffice Go API (v2)"
  spec.description = "A client for the PowerOffice Go API v2: client-credentials authentication, onboarding " \
    "and the accounting resources SERVOS posts to. Plain Ruby, no runtime dependencies."
  spec.homepage = "https://github.com/servos-app/power_office"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]
end
