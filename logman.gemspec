
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logman/version"

Gem::Specification.new do |spec|
  spec.name          = "logman"
  spec.version       = Logman::VERSION
  spec.authors       = ["Igor Šarčević"]
  spec.email         = ["igor@renderedtext.com"]

  spec.summary       = %q{Logman, formalized logging micro-abstraction}
  spec.description   = %q{Logman, formalized logging micro-abstraction}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.13"
  spec.add_development_dependency "rubocop", "~> 0.47"
  spec.add_development_dependency "rubocop-rspec", "~> 1.13"
  spec.add_development_dependency "reek", "~> 4.5"
  spec.add_development_dependency "timecop", "~> 0.9"
end
