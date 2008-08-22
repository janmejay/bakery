require File.join(File.dirname(__FILE__), "..", "util", "actions")

class Button
  
  include Actions::ActiveRectangleSubscriber
  
  def initialize(owner, view_options, callback_name)
    @x, @y, @z = view_options[:x], view_options[:y], view_options[:z]
    @dx, @dy = view_options[:dx], view_options[:dy]
    @owner = owner
    @window = @owner.is_a?(Bakery::Window) ? @owner : @owner.window
    @callback_name = callback_name
    @body = Gosu::Image.new(@window.window, "media/#{view_options[:image] || @callback_name}_button.png", true)
  end
  
  def activate
    @window.register(self)
  end
  
  def deactivate
    @window.unregister(self)
  end
  
  def handle(event)
    @owner.send(@callback_name)
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