class ActionEvent::Message

  cattr_accessor :default_queue, :instance_writer => false
  @@default_queue = :medium
  
  def self.deliver(queue_name, event, params = {})
    with_queue(queue_name) { |queue| queue.publish(Marshal.dump({:event => event, :params => params})) }
  end

  def self.try_to_get_next_message(*queues)
    queues.flatten.each do |queue_name|
      if message = with_queue(queue_name) { |queue| m = queue.pop; m ? Marshal.load(m) : nil }
        return { :queue_name => queue_name, :event => message[:event], :params => message[:params] }
      end
    end
    return nil
  end

  def self.queue_status(*queues)
    queues.flatten.inject({}) do |hash, queue_name|
      hash[queue_name] = with_queue(queue_name) { |queue| queue.status }
      hash
    end
  end

protected

  def self.with_queue(queue_name, &block)
    queue_name = queue_name.to_s
    @config ||= YAML.load(File.read(File.join(RAILS_ROOT, 'config', 'rabbitmq.yml')))[RAILS_ENV]
    @queues ||= {}
    yield @queues[queue_name] ||= Carrot.new(:host => @config['rabbitmq_server']).queue("#{@config['application_name']}-#{queue_name}")
  rescue => e
    @queues[queue_name] = nil
    puts e
    RAILS_DEFAULT_LOGGER.error "ERROR: #{e}"
  end

end
