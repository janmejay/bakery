class Title
  def initialize bakery_window, size, x, y, z = 0
    @font = Gosu::Font.new(bakery_window.window, 'media/title.ttf', size)
    @x, @y, @z = x, y, z
  end
  
  def draw
    @font.draw('BakerY', @x, @y, @z, 1.0, 1.0, 0x55000000)
  end
end