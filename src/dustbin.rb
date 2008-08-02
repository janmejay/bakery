# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/position_animation'
require 'util/actions'

class Dustbin
  include Actions::ActiveRectangleSubscriber
  
  HEIGHT = 120
  
  def initialize window
    @window = window
    @image = Gosu::Image.new(@window, 'media/dustbin.png', true)
    @throwing_anim = Util::PositionAnimation.new({:x => 865, :y => 166}, {:x => 790, :y => 166}, 40, true, {50 => lambda {ask_for_waste_cake}, 99 => lambda {discard_the_cake}})
    perform_updates
  end

  def perform_updates
    @x, @y = @throwing_anim.hop
    @cake && @cake.update_position(@x + 30, @y + 60, @cake_throwing_angle)
  end
  
  def render
    @image.draw(@x, @y, zindex)
    @cake && @cake.render(ZOrder::CAKE_IN_DUSTBIN)
  end
  
  def handle(event)
    baker = @window.baker
    baker.walk_down_and_trigger(event.x, event.y) do
      baker.has_plate? && open
    end
  end
  
  def zindex
    ZOrder::UNDER_TABLE_EQUIPMENTS
  end
  
  def accept_plate plate
    @window.unregister(plate)
    @cake = plate.cake
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
    @throwing_anim.start
  end
  
  def ask_for_waste_cake
    @window.baker.give_plate_to(self)
    @cake_throwing_angle = rand(360)
  end
  
  def discard_the_cake
    @cake = nil
  end
end
