require 'test_helper'

class ActionEventTest < ActiveSupport::TestCase
  test "all objects have queue_action_event" do
    assert respond_to?(:queue_action_event)
  end
  
  test "queue_action_event create a test message" do
    assert_nil get_next_message
    queue_action_event('test')
    assert_equal get_next_message.event, 'test'
    assert_nil get_next_message
  end
  
  test "params are serialized" do
    params = {:a => 1, :b => [1,2,3]}
    queue_action_event('test', params)
    assert get_next_message.params == params
  end
  
  test "priority of queues is respected in the same day" do
    queue_action_event('test_low', :queue => :low)
    queue_action_event('test_medium', :queue => :medium)
    queue_action_event('test_high', :queue => :high)
    assert_equal get_next_message.event, 'test_high'
    assert_equal get_next_message.event, 'test_medium'
    assert_equal get_next_message.event, 'test_low'
  end
  
  test "yesterday is processed before today" do
    override_time_for_queues(1.day) { queue_action_event('test_yesterday') }
    override_time_for_queues(2.day) { queue_action_event('test_two_days_ago') }
    queue_action_event('test_today')
    assert_equal get_next_message.event, 'test_two_days_ago'
    assert_equal get_next_message.event, 'test_yesterday'
    assert_equal get_next_message.event, 'test_today'
  end
  
  test "priority is preserved across days" do
    queue_action_event('test_low', :queue => :low)
    override_time_for_queues(1.day) { queue_action_event('test_high', :queue => :high) }
    override_time_for_queues(2.day) { queue_action_event('test_medium', :queue => :medium) }
    assert_equal get_next_message.event, 'test_high'
    assert_equal get_next_message.event, 'test_medium'
    assert_equal get_next_message.event, 'test_low'
  end

  test "cleanup doesn't delete bad data" do
    ActionEvent::Message.reset!
    assert_equal ActionEvent::Message.send(:all_message_tables).length, 0
    assert_nil get_next_message

    queue_action_event('test1')
    ActionEvent::Message.cleanup!

    override_time_for_queues(1.day) { queue_action_event('test2') }
    ActionEvent::Message.cleanup!

    override_time_for_queues(2.day) { queue_action_event('test3') }
    ActionEvent::Message.cleanup!
    
    assert_equal get_next_message.event, 'test3'
    ActionEvent::Message.cleanup!

    assert_equal get_next_message.event, 'test2'
    ActionEvent::Message.cleanup!

    assert_equal get_next_message.event, 'test1'
    ActionEvent::Message.cleanup!
    
    assert_nil get_next_message
  end

protected

  def get_next_message
    ActionEvent::Message.try_to_get_next_message([:high, :medium, :low])
  end

  def override_time_for_queues(time_offset, &block)
    ActionEvent::Message.class_eval %(
      class << self
        alias :original_current_table_name_for_queue :current_table_name_for_queue
        def current_table_name_for_queue(queue_name)
          original_current_table_name_for_queue(queue_name, Time.now - #{time_offset.to_i})
        end
      end
    )
    
    yield block

    ActionEvent::Message.class_eval %(
      class << self
        alias :current_table_name_for_queue :original_current_table_name_for_queue
      end
    )
  end

end
