# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'
require 'util/actions'
require 'util/process_runner'

class Oven
  include Actions::ActiveRectangleSubscriber
  class Cake
    def initialize(oven, image_name)
      @cake_view = Gosu::Image.new(oven.window, image_name)
    end
    
    def update_position(x, y)
      @x = x
      @y = y
    end
    
    def render
      @cake_view.draw(@x, @y, ZOrder::CAKE) 
    end
  end
  
  class Plate
    def initialize(oven, cake)
      @plate_view = Gosu::Image.new(oven.window, 'media/plate.png')
      @cake = cake
    end
    
    def update_position(x, y)
      @x = x
      @y = y
      @cake.update_position(x, y)
    end
    
    def render
      @plate_view.draw(@x, @y, ZOrder::PLATE)
      @cake.render
    end
  end

  class Button
    FIRST, SECOND, THIRD, FOURTH = {:x_off => 27, :y_off => 40}, {:x_off => 60, :y_off => 64}, {:x_off => 106, :y_off => 64}, {:x_off => 138, :y_off => 40}
    
    ACTIVE_RECT_SPAN = 35
    
    include Actions::ActiveRectangleSubscriber
    def initialize(oven, base_x, base_y, name_identifier, place = FIRST)
      @x = base_x + place[:x_off]
      @y = base_y + place[:y_off]
      @oven = oven
      @cake_image_name = "media/#{name_identifier}.png"
      @body = Gosu::Image.new(@oven.window, "media/#{name_identifier}_button.png", true)
    end
    
    def handle(event)
      @oven.bake(Cake.new(@oven, @cake_image_name)) unless @oven.baking?
    end

    def render
      @body.draw(@x, @y, zindex)
    end

    def zindex
      ZOrder::OVEN_CONTROLS
    end

    protected
    def active_x
      return @x, @x + ACTIVE_RECT_SPAN
    end

    def active_y
      return @y, @y + ACTIVE_RECT_SPAN
    end
  end
  
  attr_reader :window
  
  PROCESS_RUNNER_OFFSET = {:x => 75, :y => 15}
  BAKED_CAKE_PLATE_OFFSET = {:x => 50, :y => 90}
  
  def initialize window
    @window = window
    @cake_holder_animator = Util::Animator.new(@window, 'media/oven_cake_holder.png', 200, 200, true)
    @oven_machine_view = Gosu::Image.new(@window, 'media/oven_machine.png', true)
    @baking_process = Util::ProcessRunner.new(@window, 10, 530 + PROCESS_RUNNER_OFFSET[:x], 0 + PROCESS_RUNNER_OFFSET[:y]) { eject_baked_cake }
    window.register Button.new(self, 530, 0, :circular_cake)
    window.register Button.new(self, 530, 0, :rect_cake, Button::SECOND)
    window.register Button.new(self, 530, 0, :triangular_cake, Button::THIRD)
    window.register Button.new(self, 530, 0, :heart_cake, Button::FOURTH)
    perform_updates
  end

  def perform_updates
    @cake_holder = @cake_holder_animator.slide
    @baking_process.update
  end
  
  def handle(event)
    play_animation
  end

  def render
    @cake_holder.draw(530, 0, ZOrder::OVEN_CAKE_HOLDER)
    @oven_machine_view.draw(530, 0, zindex)
    @baking_process.render
    @plate && @plate.render
  end
  
  def zindex
    ZOrder::OVEN
  end
  
  def bake(cake)
    @cake = cake
    @baking_process.start unless baking?
  end
  
  def baking?
    @baking_process.running?
  end
  
  def eject_baked_cake
    @plate = Plate.new(self, @cake)
    @plate.update_position(530 + BAKED_CAKE_PLATE_OFFSET[:x], 0 + BAKED_CAKE_PLATE_OFFSET[:y])
  end
  
  protected
  def active_x
    return 550, 715
  end
  
  def active_y
    return 60, 119
  end
  
  private
  def play_animation
    @cake_holder_animator.start
  end
end
