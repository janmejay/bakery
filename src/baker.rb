# User: janmejay.singh
# Time: 19 Jun, 2008 6:03:53 PM
class Baker

  VELOCITY = 2

  def initialize window
    @body = Gosu::Image.new(window, "media/baker.png", false)
    @window = window
    @x, @y, @target_x, @target_y, @angle = 0, 0, 0, 0, 0, 0, 0
  end

  def pointed_to x_cord, y_cord
    @target_x = x_cord
    @target_y = y_cord
  end

  def update_view
    @angle = 0 and return if almost_there
    @angle = Gosu::angle(@x, @y, @target_x, @target_y)
    dx = Gosu::offset_x(@angle, VELOCITY)
    dy = Gosu::offset_y(@angle, VELOCITY)
    @x += dx
    @y += dy
  end

  def draw
    @body.draw_rot(@x, @y, ZOrder::BAKER, @angle)
  end

  private

  def almost_there
    Gosu::distance(@x, @y, @target_x, @target_y) < 5
  end
end
