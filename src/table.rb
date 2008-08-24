# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

class Table
  def initialize context_table_data
    @context_table_data = context_table_data
  end
  
  def window= shop_window
    @shop_window = shop_window
    @table = Gosu::Image.new(@shop_window.window, @context_table_data[:table_view], true)
  end

  def draw
    @table.draw(0, 0, ZOrder::TABLE)
  end
end
