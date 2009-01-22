class Showcase
  include Actions::ActiveRectangleSubscriber
  include Oven::Plate::Handler
  
  CAKE_PLATE_OFFSET = {:x => 10, :y => 10}
  WAIT_BEFORE_REHANDLING_PLATE_XFER = 20 #loops
  
  def initialize(context_showcase_data)
    @context_showcase_data = context_showcase_data
    @x, @y = @context_showcase_data[:x], @context_showcase_data[:y]
    @enable_handler_countdown = 0
  end
  
  def window= shop_window
    @shop_window = shop_window
    @base = Gosu::Image.new(@shop_window.window, res(@context_showcase_data[:images][:base_view]), true)
    @cover = Gosu::Image.new(@shop_window.window, res(@context_showcase_data[:images][:cover_view]), true)
    @cant_put_two_cakes_in_there_message = Gosu::Sample.new(@shop_window.window, res('media/cant_put_two_cakes_in_there.ogg'))
  end
  
  def perform_updates
    @plate && @plate.update_position(@x + CAKE_PLATE_OFFSET[:x], @y + CAKE_PLATE_OFFSET[:y])
    (@enable_handler_countdown > 0) && (@enable_handler_countdown -= 1) && $logger.debug("getting ready to enable handler in #{@enable_handler_countdown} loops.")
  end

  def push_or_pop_plate baker
    (@enable_handler_countdown > 0) && return
    @plate ? give_plate_to(baker) : baker.give_plate_to(self)
    @enable_handler_countdown = WAIT_BEFORE_REHANDLING_PLATE_XFER
  end
  
  def before_accepting_plate *ignore
    @plate && @cant_put_two_cakes_in_there_message.play && return
    true
  end

  def after_accepting_plate *ignore
    @plate && @shop_window.unregister(@plate)
  end
  
  def render
    @base.draw(@x, @y, zindex)
    @cover.draw(@x, @y, ZOrder::SHOWCASE_COVER)
    @plate && @plate.render
  end
  
  def handle(event)
    @shop_window.baker.walk_down_and_trigger(event.x, event.y, :push_or_pop_plate, self)
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

