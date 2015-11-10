$:.push File.join(File.dirname(__FILE__), 'lib')

# Maintain your gem's version:
require "aspace_client/version"
require "aspace_client/helpers"
require 'aspace_client'

Gem::Specification.new do |s|
  s.name        = 'aspace_client'
  s.version     = AspaceClient::VERSION
  s.date        = '2015-11-10'
  s.summary     = "A lightweight utility to facilitate interaction with the ArchivesSpace backend API."
  s.description = "A lightweight utility to facilitate interaction with the ArchivesSpace backend API."
  s.authors     = ["Chris Fitzpatrick"]
  s.email       = 'chris.fitzpatrick@lyrasis.org'
  s.require_paths = ["lib"] 
  s.files        = Dir.glob("{bin,lib}/**/*") 
  s.homepage    =
    'https://github.com/archivesspace/aspace-client'
  s.license       = 'ECL2'
  s.add_dependency "json", "1.8.0"
  s.add_dependency 'json-schema', '1.0.10'
  s.add_dependency "puma", "2.8.2"
  s.add_dependency "net-http-persistent", "2.8"
  s.add_dependency "multipart-post", "1.2.0"
  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rspec"
end
