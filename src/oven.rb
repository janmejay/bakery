# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'
require 'util/actions'

class Oven
  include Actions::ActiveRectangleSubscriber
  
  def initialize window
    @window = window
    @oven_animator = Util::Animator.new(@window, 'media/oven_with_cake_plate.png', 200, 200, true)
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
