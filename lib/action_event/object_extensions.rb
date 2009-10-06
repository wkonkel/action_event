Object.class_eval do
  def queue_action_event(event, options={})
    queue_name = options.delete(:queue) || ActionEvent::Message.default_queue
    ActionEvent::Message.deliver(queue_name, event, options)
  end
end