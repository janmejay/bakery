module Actions
  class Event
    attr_accessor :propagatable
    attr_reader :consumers, :x, :y
    
    def initialize(macro, mouse_x, mouse_y)
      @macro, @y, @x = macro, mouse_y, mouse_x;
      @consumers = []
      @propagatable = true
    end
  end
  
  module Publisher
    def register(*listener)
      @subscribers = (@subscribers || []).concat(listener.flatten)
      @subscribers.sort!
    end
    
    def publish(event)
      for_each_subscriber { |subscriber| subscriber.consume event }
    end
    
    protected
    def for_each_subscriber
      @subscribers.each do |subscriber|
        yield subscriber
      end
    end
  end
  
  module Subscriber
    def consume(event)
      if can_consume?(event)
        handle(event)
        event.consumers << self
        event.propagatable = allow_propagation?(event)
      end
    end
    
    def <=> other
      other.zindex <=> self.zindex 
    end

    #subscribers are always renderable(because it doesn't make sense to have an invisible subscriber)
    def render
      raise 'Not Implemented.....'
    end
    
    def perform_updates; end
    
    def zindex
      raise 'Not Implemented.....'
    end
    
    private
    def can_consume?(event); false; end
    def handle(event); end
    def allow_propagation?(event); false; end
  end
  
  module ActiveRectangleSubscriber
    include Subscriber
    
    protected
    def active_x
      raise 'Not Implemented.....'
    end
    
    def active_y
      raise 'Not Implemented.....'
    end
    
    private
    def can_consume?(event)
      event.propagatable && within_active_area?(event)
    end
    
    def within_active_area?(event)
      Range.new(*active_x).member?(event.x) && Range.new(*active_y).member?(event.y)
    end
  end
end