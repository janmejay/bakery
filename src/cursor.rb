# User: janmejay.singh
# Time: 19 Jun, 2008 12:06:58 AM
class Cursor
  def window= bakery_window
    @window = bakery_window.window
    @tip = Gosu::Image.new(@window, res("media/hand.png"), true)
  end

  def draw
    @tip.draw_rot(@window.mouse_x + 3, @window.mouse_y + 14, ZOrder::CURSOR, 0)
  end
end
