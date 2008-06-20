require 'gosu'
require 'cursor'
require 'baker'
require 'table'
require 'oven'
require 'zorder'

class GameWindow < Gosu::Window
  def initialize
    super(1024, 768, false)
    self.caption = "Bakery"
    
    @background_image = Gosu::Image.new(self, "media/floor.png", true)
    
    @cursor = Cursor.new(self)
    @baker = Baker.new(self)
    @table = Table.new(self)
    @oven = Oven.new(self)

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def update
    if button_down? Gosu::Button::MsLeft
      trigger_click
    end
    @baker.update_view
    @oven.update_oven_view
  end

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    @cursor.redraw
    @baker.draw
    @table.draw
    @oven.draw
    @font.draw("Score: #{mouse_x} X #{mouse_y}", 10, 10, ZOrder::MESSAGES, 1.0, 1.0, 0xffffff00)
  end

  def trigger_click
    @baker.pointed_to(mouse_x, mouse_y)
    @oven.play_animation
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
end