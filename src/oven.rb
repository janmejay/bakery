# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'
require 'util/position_animation'
require 'util/actions'
require 'util/process_runner'

class Oven
  class Cake
    def initialize(shop_window, cake_name)
      @shop_window = shop_window
      @cake_name = cake_name
      @body = Gosu::Image.new(@shop_window.window, "media/#{@cake_name}.png")
    end
    
    def update_position(x, y, angle = nil)
      @x = x
      @y = y
      @angle = angle
    end
    
    def iced?
      not @icing_type.nil?
    end
    
    def decorated?
      not @decoration_type.nil?
    end
    
    def put_icing icing_type
      @icing_type = icing_type
      @body = Gosu::Image.new(@shop_window.window, "media/#{@icing_type}_#{@cake_name}.png")
    end
    
    def put_decoration decoration_type
      @decoration_type = decoration_type
      @decoration = Gosu::Image.new(@shop_window.window, "media/#{@decoration_type}_decoration.png")
    end
    
    def render(z_index = ZOrder::CAKE)
      if @angle
        @body.draw_rot(@x, @y, z_index, @angle)
        @decoration && @decoration.draw_rot(@x, @y, z_index, @angle)
      else
        @body.draw(@x, @y, z_index)
        @decoration && @decoration.draw(@x, @y, z_index)
      end
    end
  end
  
  class Plate
    
    include Actions::ActiveRectangleSubscriber
    attr_accessor :holder
    
    PLATE_LENGTH_AND_WIDTH = 60
    
    def initialize(shop_window, cake)
      @shop_window = shop_window
      @plate_view = Gosu::Image.new(@shop_window.window, 'media/plate.png', false)
      @cake = cake
    end
    
    def update_position(x, y)
      @x = x
      @y = y
      @cake.update_position(x, y)
    end
    
    def render(z_index = zindex)
      @plate_view.draw(@x, @y, z_index)
      @cake.render(z_index + 1)
    end
    
    def handle event
      @shop_window.baker.walk_down_and_trigger(event.x, event.y) do |baker|
        @holder.give_plate_to(baker) && @holder = nil
      end
    end
    
    def cake
      @cake
    end

    def zindex
      ZOrder::PLATE
    end
    
    protected
    def active_x
      return @x, @x + PLATE_LENGTH_AND_WIDTH
    end

    def active_y
      return @y, @y + PLATE_LENGTH_AND_WIDTH
    end
  end

  class Button
    BUTTON_OFFSETS = [{:x_off => 27, :y_off => 40}, {:x_off => 60, :y_off => 64}, {:x_off => 106, :y_off => 64}, {:x_off => 138, :y_off => 40}]
    
    ACTIVE_RECT_SPAN = 35
    
    include Actions::ActiveRectangleSubscriber
    def initialize(oven, base_x, base_y, name_identifier, place)
      @x = base_x + place[:x_off]
      @y = base_y + place[:y_off]
      @oven = oven
      @cake_name = name_identifier
      @body = Gosu::Image.new(@oven.shop_window.window, "media/#{name_identifier}_button.png", true)
    end
    
    def handle(event)
      @oven.shop_window.baker.walk_down_and_trigger(event.x, event.y) do
        @oven.bake(Cake.new(@oven.shop_window, @cake_name)) unless @oven.baking?
      end
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
  
  attr_reader :shop_window
  
  PROCESS_RUNNER_OFFSET = {:x => 75, :y => 15}
  BAKED_CAKE_PLATE_OFFSET = {:x => 70, :y => 110}
  
  def initialize shop_window, context_oven_data
    @shop_window = shop_window
    @x, @y = context_oven_data[:x], context_oven_data[:y]
    @cake_holder = Gosu::Image.new(@shop_window.window, context_oven_data[:images][:cake_holder], true)
    @trash_can = Gosu::Image.new(@shop_window.window, context_oven_data[:images][:trash_can], true)
    @oven_machine_view = Gosu::Image.new(@shop_window.window, context_oven_data[:images][:machine_view], true)
    @cake_plate_pos_anim = Util::PositionAnimation.new({:x => @x, :y => @y}, {:x => @x, :y => @y-100}, 40, true, {49 => :put_baked_cake, 99 => :make_plate_pickable}, self)
    @baking_process = Util::ProcessRunner.new(@shop_window.window, 10, @x + PROCESS_RUNNER_OFFSET[:x], @y + PROCESS_RUNNER_OFFSET[:y], :eject_baked_cake, self)
    context_oven_data[:buttons].each_with_index do |button, index|
      @shop_window.register Button.new(self, @x, @y, button, Button::BUTTON_OFFSETS[index])
    end
    update
  end

  def update
    @baking_process.update
    @cake_tray_x, @cake_tray_y = @cake_plate_pos_anim.hop
    @plate && @plate.update_position(@cake_tray_x + BAKED_CAKE_PLATE_OFFSET[:x], @cake_tray_y + BAKED_CAKE_PLATE_OFFSET[:y])
  end
  
  def give_plate_to(baker)
    baker.accept_plate(@plate) && @plate = nil
  end

  def draw
    @oven_machine_view.draw(@x, @y, ZOrder::OVEN)
    @trash_can.draw(@x, @y, ZOrder::OVEN_TRASH_CAN)
    @baking_process.render
    render_cake_holder
  end
  
  def bake(cake)
    @shop_window.baker.pay(-30)
    @cake = cake
    @baking_process.start unless baking?
  end
  
  def baking?
    @baking_process.running?
  end
  
  def eject_baked_cake
    @cake_plate_pos_anim.start
  end
  
  def put_baked_cake *ignore
    @plate = Plate.new(self.shop_window, @cake)
    @plate.holder = self
  end
  
  def make_plate_pickable *ignore
    @shop_window.register @plate
  end
  
  private
  def render_cake_holder
    args = @cake_plate_pos_anim.hop
    @cake_holder.draw(@cake_tray_x, @cake_tray_y, ZOrder::OVEN_CAKE_HOLDER)
    @plate && @plate.render
  end
end
