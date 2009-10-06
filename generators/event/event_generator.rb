class EventGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # if there's not an app/events directory, do an initial install
      unless File.exists?("#{RAILS_ROOT}/app/events")
        #m.migration_template 'migration.rb', "db/migrate", { :migration_file_name => "create_action_event_tables" }
        m.file 'poller', 'script/poller', :chmod => 0755
        m.directory 'app/events'
        m.file 'application_event.rb', 'app/events/application_event.rb'
      end
      
      # generate this event
      m.class_collisions "#{class_name}Event"
      m.directory File.join('app/events', class_path)
      m.template 'event.rb', File.join('app/events', class_path, "#{file_name}_event.rb")
    end
  end
end
