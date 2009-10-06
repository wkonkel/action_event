module ActionEvent
  class Base

    include ActionController::UrlWriter
    
    attr_accessor :params
    
    def self.view_paths
      @view_paths ||= ActionView::Base.process_view_paths(Rails::Configuration.new.view_path)
    end

    def initialize(params)
      @params = params.clone
    end

    def self.process(params={})
      action_event = new(params)
      filter_chain.each { |chain| action_event.send(chain) }
      action_event.process
    end

    def self.before_filter(method)
      filter_chain.push(method.to_sym)
    end

    def self.skip_before_filter(method)
      filter_chain.delete(method.to_sym)
    end

    def self.helper(*names)
      names.each do |name|
        case name
          when String, Symbol then helper("#{name.to_s.underscore}_helper".classify.constantize)
          when Module then master_helper_module.module_eval { include name }
          else raise
        end
      end
    end

  protected

    def template
      unless @template
        @template = ActionView::Base.new(ActionEvent::Base.view_paths, {}, self)
        @template.extend ApplicationHelper
        @template.extend self.class.master_helper_module
        @template.instance_eval { def protect_against_forgery?; false; end }
      end
      @template
    end
    
    def method_missing(method, *params, &block)
      template.send(method, *params, &block)
    end

    def self.filter_chain
      unless chain = read_inheritable_attribute('filter_chain')
        chain = Array.new
        write_inheritable_attribute('filter_chain', chain)
      end
      return chain
    end

    def self.controller_path
      @controller_path ||= name.gsub(/Event$/, '').underscore
    end

    def self.master_helper_module
      unless mod = read_inheritable_attribute('master_helper_module')
        mod = Module.new
        write_inheritable_attribute('master_helper_module', mod)
      end
      return mod
    end

  end
end