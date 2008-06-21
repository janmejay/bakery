# User: janmejay.singh
# Time: 19 Jun, 2008 6:03:53 PM
class Baker

  class LimitingRectangle
    def initialize top_left_x, top_left_y, bottom_right_x, bottom_right_y
      @min_x = top_left_x
      @min_y = top_left_y
      @max_x = bottom_right_x
      @max_y = bottom_right_y
    end

    def sanatize x, y
      x = @min_x if x < @min_x
      y = @min_y if y < @min_y
      x = @max_x if x > @max_x
      y = @max_y if y > @max_y
      return x, y
    end
  end

  VELOCITY = 2

  def initialize window
    @body = Gosu::Image.new(window, "media/baker.png", false)
    @window = window
    @x, @y, @target_x, @target_y, @angle = 0, 0, 0, 0, 0, 0, 0
    @sane_walking_area = LimitingRectangle.new(384, 178, 835, 550)
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
    @x, @y = @sane_walking_area.sanatize @x, @y
  end

  def draw
    @body.draw_rot(@x, @y, ZOrder::BAKER, 0)
  end

  private

  def almost_there
    Gosu::distance(@x, @y, @target_x, @target_y) < 5
  end
end
