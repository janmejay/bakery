# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'
require 'util/actions'

class Oven
  include Actions::ActiveRectangleSubscriber
  class Cake
    def initialize(oven, image_name)
      @cake_view = Gosu::Image.new(oven.window, image_name, true)
    end
    
    def update_position_wrt(plate)
      @x = plate.x
      @y = plate.y
    end
    
    def render
      @cake_view.draw(@x, @y, ZOrder::CAKE) 
    end
  end
  
  class Plate
    def initialize(oven)
      @plate_view = Gosu::Image.new(oven.window, 'media/plate.png', true)
    end
    
    def update_position(x, y)
      @x = x
      @y = y
    end
    
    def render
      @plate_view.draw(@x, @y, ZOrder::PLATE)
    end
  end

  class Button
    FIRST, SECOND, THIRD, FOURTH = {:x_off => 27, :y_off => 40}, {:x_off => 60, :y_off => 64}, {:x_off => 106, :y_off => 64}, {:x_off => 138, :y_off => 40}
    
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
      return @x, @x + 35
    end

    def active_y
      return @y, @y + 35
    end
  end
  
  attr_reader :window
  
  def initialize window
    @window = window
    @cake_holder_animator = Util::Animator.new(@window, 'media/oven_cake_holder.png', 200, 200, true)
    @oven_machine_view = Gosu::Image.new(@window, 'media/oven_machine.png', true)
    window.register Button.new(self, 530, 0, :circular_cake)
    window.register Button.new(self, 530, 0, :rect_cake, Button::SECOND)
    window.register Button.new(self, 530, 0, :triangular_cake, Button::THIRD)
    window.register Button.new(self, 530, 0, :heart_cake, Button::FOURTH)
    perform_updates
  end

  def perform_updates
    @cake_holder = @cake_holder_animator.slide
  end
  
  def handle(event)
    play_animation
  end

  def render
    @cake_holder.draw(530, 0, ZOrder::OVEN_CAKE_HOLDER)
    @oven_machine_view.draw(530, 0, zindex)
  end
  
  def zindex
    ZOrder::OVEN
  end
  
  def bake(cake)
    puts "Got Bake Request for #{cake.inspect}"
  end
  
  def baking?
    false
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
