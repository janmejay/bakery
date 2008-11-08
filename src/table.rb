# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

class Table
  def window= shop_window
    @shop_window = shop_window
    @table = Gosu::Image.new(@shop_window.window, @shop_window.level.table_image, true)
  end

  def draw
    @table.draw(0, 0, ZOrder::TABLE)
  end
end
