# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'
require 'util/actions'

class Dustbin
  include Actions::ActiveRectangleSubscriber
  
  HEIGHT = 150
  def initialize window
    @window = window
    @dustbin_animator = Util::Animator.new(@window, 'media/opening_dustbin.png', 150, 120, true)
    perform_updates
  end

  def perform_updates
    @dustbin = @dustbin_animator.slide
  end
  
  def render
    @dustbin.draw(790, HEIGHT, zindex)
  end
  
  def handle(event)
    open
  end
  
  def zindex
    ZOrder::UNDER_TABLE_EQUIPMENTS
  end
  
  protected
  def active_x
    return 865, 896
  end
  
  def active_y
    return 166, 166 + HEIGHT
  end
  
  private

  def open
    @dustbin_animator.start
  end
end
