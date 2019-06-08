require_relative "lib/graphiti/open_api/version"

Gem::Specification.new do |spec|
  spec.name = "graphiti-openapi"
  spec.version = Graphiti::OpenAPI::VERSION
  spec.authors = ["Alex Semyonov"]
  spec.email = ["alex@semyonov.us"]

  spec.summary = %q{OpenAPI 3.0 specification for your (Graphiti) JSON:API}
  spec.description = spec.summary
  spec.homepage = "https://github.com/alsemyonov/graphiti-openapi"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "railties", "~> 5.2.2"
  spec.add_runtime_dependency "activemodel"
  spec.add_runtime_dependency "responders"
  spec.add_runtime_dependency "kaminari"
  spec.add_runtime_dependency "graphiti", "~> 1.2.0"
  spec.add_runtime_dependency "dry-struct", "~> 0.7"
  spec.add_runtime_dependency "transproc"
  spec.add_runtime_dependency "webpacker"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 3.8"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rufo"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "graphiti_spec_helpers"
  spec.add_development_dependency "factory_bot_rails"
end
