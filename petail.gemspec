# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "petail"
  spec.version = "0.0.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/petail"
  spec.summary = "A RFC 7807 Problem Details for HTTP APIs implementation."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/petail/issues",
    "changelog_uri" => "https://alchemists.io/projects/petail/versions",
    "homepage_uri" => "https://alchemists.io/projects/petail",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Petail",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/petail"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.4"
  spec.add_dependency "rack", "~> 3.1"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
