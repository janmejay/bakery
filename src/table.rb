# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

class Table
  def initialize shop_window
    @shop_window = shop_window
    @table = Gosu::Image.new(@shop_window.window, "media/table.png", true)
  end

  def draw
    @table.draw(0, 0, ZOrder::TABLE)
  end
end
