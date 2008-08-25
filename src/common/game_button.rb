require File.join(File.dirname(__FILE__), 'button')

class GameButton < Button
  
  def handle(event)
    @owner.window.baker.walk_down_and_trigger(event.x, event.y, @callback, @owner)
  end
end