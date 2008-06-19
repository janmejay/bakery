require 'gosu'
require 'cursor'
require 'baker'
require 'zorder'

class GameWindow < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = "Bakery"
    
    @background_image = Gosu::Image.new(self, "media/bakery.png", true)
    
    @cursor = Cursor.new(self)
    @baker = Baker.new(self)

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def update
    if button_down? Gosu::Button::MsLeft
      trigger_click
    end
    @baker.update_view
  end

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    @cursor.redraw
    @baker.draw
    @font.draw("Score: #{mouse_x} X #{mouse_y}", 10, 10, ZOrder::MESSAGES, 1.0, 1.0, 0xffffff00)
  end

  def trigger_click
    @baker.pointed_to(mouse_x, mouse_y)
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
end