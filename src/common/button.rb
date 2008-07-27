require File.join(File.dirname(__FILE__), "..", "util", "actions")

class Button
  
  include Actions::ActiveRectangleSubscriber
  
  def initialize(owner, view_options, callback_name)
    @x, @y, @z = view_options[:x], view_options[:y], view_options[:z]
    @dx, @dy = view_options[:dx], view_options[:dy]
    @owner = owner
    @callback_name = callback_name
    @body = Gosu::Image.new(@owner.window, "media/#{@callback_name}_button.png", true)
  end
  
  def activate
    @owner.window.register(self)
  end
  
  def deactivate
    @owner.window.unregister(self)
  end
  
  def handle(event)
    puts "First... i was called...."
    @owner.window.baker.walk_down_and_trigger(event.x, event.y) do
      puts "Invoked.... "
      @owner.send(@callback_name)
    end
  end

  def render
    @body.draw(@x, @y, zindex)
  end

  def zindex
    @z
  end

  protected
  def active_x
    return @x, @x + @dx
  end

  def active_y
    return @y, @y + @dy
  end
end