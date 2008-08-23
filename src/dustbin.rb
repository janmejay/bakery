# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/position_animation'
require 'util/actions'

class Dustbin
  include Actions::ActiveRectangleSubscriber
  
  def initialize shop_window, context_dustbin_data
    @shop_window = shop_window
    @height = context_dustbin_data[:height]
    @image = Gosu::Image.new(@shop_window.window, context_dustbin_data[:bin_view], true)
    @throwing_anim = Util::PositionAnimation.new(context_dustbin_data[:inactive], context_dustbin_data[:active], 40, true, {50 => lambda {ask_for_waste_cake}, 99 => lambda {discard_the_cake}})
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
    baker = @shop_window.baker
    baker.walk_down_and_trigger(event.x, event.y) do
      baker.has_plate? && open
    end
  end
  
  def zindex
    ZOrder::UNDER_TABLE_EQUIPMENTS
  end
  
  def accept_plate plate
    @shop_window.unregister(plate)
    @cake = plate.cake
  end
  
  protected
  def active_x
    return 865, 896
  end
  
  def active_y
    return 166, 166 + @height
  end
  
  private

  def open
    @throwing_anim.start
  end
  
  def ask_for_waste_cake
    @shop_window.baker.give_plate_to(self)
    @cake_throwing_angle = rand(360)
  end
  
  def discard_the_cake
    @cake = nil
  end
end
