# User: janmejay.singh
# Time: 19 Jun, 2008 6:03:53 PM

require File.join('util', 'geometry')
require File.join('util', 'font_animator')

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
  
  attr_reader :plate
  include Oven::Plate::Handler

  def initialize context
    @walk_amin_options = {:run_indefinitly => true, :callback_map => {25 => :play_step, 75 => :play_step}, :callback_receiver => self}
    @walking_anim = Util::Animator.new(res('media/walking_baker.png'), 105, 80, {:chunk_slice_width => 2}.merge(@walk_amin_options))
    @velocity = 2
    @x, @y, @target_x, @target_y, @angle = 600, 400, 600, 400, 180
    @sane_walking_area = LimitingRectangle.new(384, 170, 835, 550)
  end
  
  def wear_shoes shoes
    @velocity = shoes.speed
    @walking_anim = Util::Animator.new(res('media/walking_baker.png'), 105, 80, {:chunk_slice_width => shoes.walking_anim_slice_width}.merge(@walk_amin_options))
    @walking_anim.window = @shop_window.window
  end
  
  def window= shop_window
    @shop_window = shop_window
    @walking_anim.window = @shop_window.window
    @hat = Gosu::Image.new(@shop_window.window, res('media/baker_hat.png'), false)
    @cant_pick_two_plates_at_a_time = Gosu::Sample.new(@shop_window.window, res('media/cant_pick_two_plates_at_a_time.ogg'))
    @loss_anim = Util::FontAnimator.new(@shop_window, 120, :z => ZOrder::MESSAGES, :color => 'ff0000', :font_name => res('media/number.ttf'))
    @profit_anim = Util::FontAnimator.new(@shop_window, 120, :z => ZOrder::MESSAGES, :color => '00ff00', :font_name => res('media/number.ttf'))
    @profit_sound = Gosu::Sample.new(@shop_window.window, res('media/gain_sound.ogg'))
    @loss_sound = Gosu::Sample.new(@shop_window.window, res('media/loss_sound.ogg'))
    @plate && @plate.window = @shop_window
    @step_sound = Gosu::Sample.new(@shop_window.window, res('media/baker_walk.ogg'))
  end
  
  def walk_down_and_trigger(x_cord, y_cord, trigger_when_reached = nil, trigger_on = nil)
    @target_x, @target_y = @sane_walking_area.sanatize x_cord, y_cord
    @walking_anim.start
    @trigger_when_reached = trigger_when_reached
    @trigger_on = trigger_on
  end
  
  def before_accepting_plate *ignore
    @plate && @cant_pick_two_plates_at_a_time.play && return
    true
  end
  
  def after_accepting_plate
    @shop_window.unregister(@plate)
  end

  def before_giving_plate
    @shop_window.register(@plate)
  end
  
  def has_plate?
    @plate
  end
  
  def is_plate_equal_to? this_plate
    @plate.content == this_plate.content
  end

  def update
    @plate && @plate.update_position(*offset(PLATE_HOLDING_OFFSET_ANGLE, PLATE_HOLDING_OFFSET, Oven::Plate::PLATE_LENGTH_AND_WIDTH, Oven::Plate::PLATE_LENGTH_AND_WIDTH))
    if almost_there && @walking_anim.running?
      @walking_anim.stop
      @trigger_when_reached && @trigger_on.send(@trigger_when_reached, self)
      @trigger_when_reached = false
    end
    almost_there && return
    @angle = Gosu::angle(@x, @y, @target_x, @target_y)
    @x += Gosu::offset_x(@angle, @velocity)
    @y += Gosu::offset_y(@angle, @velocity)
  end

  def draw
    @walking_anim.slide.draw_rot(@x, @y, ZOrder::BAKER, @angle)
    @hat.draw_rot(@x, @y, ZOrder::BAKER_HAT, @angle)
    @plate && @plate.render(ZOrder::PLATE_WHEN_IN_BAKERS_HAND)
  end
  
  def pay bucks
    $logger.debug("Baker is going to pay -> #{bucks}")
    @loss_anim.start_anim bucks.to_s, :x => @x, :y => @y
    @shop_window.money_drawer.withdraw(bucks)
    @loss_sound.play
    $logger.debug("Baker paid #{bucks}... left with #{@shop_window.money_drawer.money}.")
  end
  
  def accept_payment bucks
    @profit_anim.start_anim bucks.to_s, :x => @x, :y => @y
    @shop_window.money_drawer.deposit(bucks)
    @profit_sound.play
    $logger.debug("Baker got #{bucks}... left with #{@shop_window.money_drawer.money}.")
  end

  def play_step
    @step_sound.play
  end

  private

  def almost_there
    Gosu::distance(@x, @y, @target_x, @target_y) < 5
  end
end
