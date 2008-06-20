# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

class Table
  def initialize window
    @window = window
    @table = Gosu::Image.new(window, "media/table.png", true)
  end

  def draw
    @table.draw(0, 0, ZOrder::TABLE)
  end
end
