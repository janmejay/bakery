class Showcase
  include Actions::ActiveRectangleSubscriber
  
  CAKE_PLATE_OFFSET = {:x => 10, :y => 10}
  
  def initialize(context_showcase_data)
    @context_showcase_data = context_showcase_data
    @x, @y = @context_showcase_data[:x], @context_showcase_data[:y]
  end
  
  def window= shop_window
    @shop_window = shop_window
    @base = Gosu::Image.new(@shop_window.window, @context_showcase_data[:images][:base_view], true)
    @cover = Gosu::Image.new(@shop_window.window, @context_showcase_data[:images][:cover_view], true)
    @cant_put_two_cakes_in_there_message = Gosu::Sample.new(@shop_window.window, 'media/cant_put_two_cakes_in_there.ogg')
  end
  
  def perform_updates
    @plate && @plate.update_position(@x + CAKE_PLATE_OFFSET[:x], @y + CAKE_PLATE_OFFSET[:y])
  end
  
  def receive_cake
    @plate && @cant_put_two_cakes_in_there_message.play && return
    @shop_window.baker.give_plate_to(self)
    return unless @plate && @plate.holder = self
  end
  
  def give_plate_to baker
    baker.accept_plate(@plate) && @plate = nil
  end
  
  def accept_plate plate
    @plate = plate
  end

  def render
    @base.draw(@x, @y, zindex)
    @cover.draw(@x, @y, ZOrder::SHOWCASE_COVER)
    @plate && @plate.render
  end
  
  def handle(event)
    @shop_window.baker.walk_down_and_trigger(event.x, event.y) do
      receive_cake
    end
  end

  def zindex
    ZOrder::TABLE_MOUNTED_EQUIPMENTS
  end

  protected
  def active_x
    return @x, @x + 80
  end

  def active_y
    return @y, @y + 80
  end
end

