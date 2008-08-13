class Title
  def initialize window, size, x, y, z = 0
    @font = Gosu::Font.new(window, 'media/title.ttf', size)
    @x, @y, @z = x, y, z
  end
  
  def draw
    @font.draw('BakerY', @x, @y, @z, 1.0, 1.0, 0x55000000)
  end
end