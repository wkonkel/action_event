Gem::Specification.new do |s|
  s.name     = "action_event"
  s.version  = "0.0.3"
  s.date     = "2009-10-06"
  s.summary  = "A framework for asynchronous message processing in a Rails application."
  s.email    = "wkonkel@gmail.com"
  s.homepage = "http://github.com/wkonkel/action_event"
  s.description = "A framework for asynchronous message processing in a Rails application."
  s.has_rdoc = false
  s.authors  = ["Warren Konkel"]
  s.files    = Dir.glob('**/*') - Dir.glob('test/*.rb')
  s.test_files = Dir.glob('test/*.rb')
  s.require_paths = ["lib"]
end