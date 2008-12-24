# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/position_animation'
require 'util/actions'

class Dustbin
  include Actions::ActiveRectangleSubscriber
  
  def initialize context_dustbin_data
    @context_dustbin_data = context_dustbin_data
    @height = context_dustbin_data[:height]
    @throwing_anim = Util::PositionAnimation.new(@context_dustbin_data[:inactive], @context_dustbin_data[:active], 40, true, {50 => :ask_for_waste_cake, 99 => :discard_the_cake}, self)
    perform_updates
  end
  
  def window= shop_window
    @shop_window = shop_window
    @image = Gosu::Image.new(@shop_window.window, @context_dustbin_data[:bin_view], true)
  end

  def perform_updates
    @x, @y = @throwing_anim.hop
    @content && @content.update_position(@x + 30, @y + 60, @content_throwing_angle)
  end
  
  def render
    @image.draw(@x, @y, zindex)
    @content && @content.render(ZOrder::CAKE_IN_DUSTBIN)
  end
  
  def handle(event)
    baker = @shop_window.baker
    baker.walk_down_and_trigger(event.x, event.y, :receive_trash_cake, self)
  end
  
  def receive_trash_cake baker
    baker.has_plate? && open
  end
  
  def zindex
    ZOrder::UNDER_TABLE_EQUIPMENTS
  end
  
  def accept_plate plate
    @shop_window.unregister(plate)
    @content = plate.content
    @shop_window.baker.pay(Shop::PriceCalculator.cost_price_for(@content))
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
  
  def ask_for_waste_cake *ignore
    @shop_window.baker.give_plate_to(self)
    @content_throwing_angle = rand(360)
  end
  
  def discard_the_cake *ignore
    @content = nil
  end
end
