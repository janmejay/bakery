# User: janmejay.singh
# Time: 19 Jun, 2008 12:06:58 AM
class Cursor
  def initialize(window)
    @window = window
    @tip = Gosu::Image.new(window, "media/hand.png", true)
  end

  def draw
    @tip.draw_rot(@window.mouse_x + 3, @window.mouse_y + 14, ZOrder::CURSOR, 0)
  end
end