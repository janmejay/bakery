# User: janmejay.singh
# Time: 19 Jun, 2008 6:03:53 PM

require File.join('util', 'geometry')

class Baker
  
  PLATE_HOLDING_OFFSET_ANGLE = 70
  PLATE_HOLDING_OFFSET = 40
  
  include Util::Geometry

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
    @walking_anim = Util::Animator.new(window, 'media/walking_baker.png', 105, 80, false, 2, true)
    @window = window
    @x, @y, @target_x, @target_y, @angle = 0, 0, 0, 0, 0, 0, 0
    @sane_walking_area = LimitingRectangle.new(384, 200, 835, 550)
  end
  
  def walk_down_and_trigger(x_cord, y_cord, &trigger)
    @target_x, @target_y = @sane_walking_area.sanatize x_cord, y_cord
    @walking_anim.start
    @trigger_when_reached = trigger
  end
  
  def pick_up_plate(plate)
    @plate = plate
  end

  def update
    return if almost_there
    @angle = Gosu::angle(@x, @y, @target_x, @target_y)
    @x += Gosu::offset_x(@angle, VELOCITY)
    @y += Gosu::offset_y(@angle, VELOCITY)
    @plate && @plate.update_position(*offset(PLATE_HOLDING_OFFSET_ANGLE, PLATE_HOLDING_OFFSET, Oven::Plate::PLATE_LENGTH_AND_WIDTH, Oven::Plate::PLATE_LENGTH_AND_WIDTH))
    if (almost_there)
      @walking_anim.stop
      @trigger_when_reached && @trigger_when_reached.call(self)
    end
  end

  def draw
    @walking_anim.slide.draw_rot(@x, @y, ZOrder::BAKER, @angle)
    @plate && @plate.render
  end

  private

  def almost_there
    Gosu::distance(@x, @y, @target_x, @target_y) < 5
  end
end
