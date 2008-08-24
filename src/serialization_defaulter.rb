module SerializationDefaulter
  def self.included(base)
    base.extend ClassMethods
  end
  
  def _dump depth
    return ''
  end
  
  module ClassMethods
    def _load serialized_window
      return nil
    end
  end
end

Gosu::Window.send(:include, SerializationDefaulter)
Gosu::Image.send(:include, SerializationDefaulter)
Gosu::Sample.send(:include, SerializationDefaulter)
Gosu::Font.send(:include, SerializationDefaulter)