require 'action_event/base'
require 'action_event/object_extensions'
require 'action_event/message'
ActiveSupport::Dependencies.load_paths << File.join(RAILS_ROOT, 'app/events')

puts "RUNNING INIT"