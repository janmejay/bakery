# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'
require 'util/actions'

class Oven
  include Actions::ActiveRectangleSubscriber
  class Button
    FIRST, SECOND, THIRD, FOURTH = {:x_off => 25, :y_off => 40}, {:x_off => 60, :y_off => 64}, {:x_off => 106, :y_off => 64}, {:x_off => 141, :y_off => 40}
    
    include Actions::ActiveRectangleSubscriber
    def initialize(oven, base_x, base_y, path, place = FIRST)
      @x = base_x + place[:x_off]
      @y = base_y + place[:y_off]
      @body = Gosu::Image.new(oven.window, path, true)
    end
    
    def handle(event)
      puts "I received..... Damn...."
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
    @oven_animator = Util::Animator.new(@window, 'media/oven_with_cake_plate.png', 200, 200, true)
    window.register Button.new(self, 530, 0, 'media/circular_cake_button.png')
    window.register Button.new(self, 530, 0, 'media/rect_cake_button.png', Button::SECOND)
    window.register Button.new(self, 530, 0, 'media/trianglar_cake_button.png', Button::THIRD)
    window.register Button.new(self, 530, 0, 'media/heart_cake_button.png', Button::FOURTH)
    perform_updates
  end

  def perform_updates
    @oven = @oven_animator.slide
  end
  
  def handle(event)
    play_animation
  end

  def render
    @oven.draw(530, 0, zindex)
  end
  
  def zindex
    ZOrder::EQUIPMENTS
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
    @oven_animator.start
  end
end
