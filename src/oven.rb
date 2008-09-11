# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'
require 'util/position_animation'
require 'util/actions'
require 'util/process_runner'

class Oven
  class Cake
    def initialize(cake_name)
      @cake_name = cake_name
    end
    
    def window= shop_window
      @shop_window = shop_window
      cake_name = @icing_type ? "media/#{@icing_type}_#{@cake_name}.png" : "media/#{@cake_name}.png"
      @body = Gosu::Image.new(@shop_window.window, cake_name)
      @decoration_type && @decoration = Gosu::Image.new(@shop_window.window, "media/#{@decoration_type}_decoration.png")
    end
    
    def update_position(x, y, angle = nil)
      @x = x
      @y = y
      @angle = angle
    end
    
    def iced?
      topped? ? @top_icing_type : @icing_type
    end
    
    def decorated?
      @decoration_type
    end
    
    def topped?
      @topping_type
    end
    
    def put_icing icing_type
      if topped?
        @top_icing_type = icing_type
        @topping = Gosu::Image.new(@shop_window.window, "media/#{@top_icing_type}_#{@topping_type}.png")
      else
        @icing_type = icing_type
        @body = Gosu::Image.new(@shop_window.window, "media/#{@icing_type}_#{@cake_name}.png")
      end
    end
    
    def put_decoration decoration_type
      @decoration_type = decoration_type
      @decoration = Gosu::Image.new(@shop_window.window, "media/#{@decoration_type}_decoration.png")
    end
    
    def put_topping topping_type
      @topping_type = topping_type
      @topping = Gosu::Image.new(@shop_window.window, "media/#{@topping_type}.png")
    end
    
    def render(z_index = ZOrder::CAKE)
      if @angle
        @body.draw_rot(@x, @y, z_index, @angle)
        @topping && @topping.draw_rot(@x, @y, z_index, @angle)
        @decoration && @decoration.draw_rot(@x, @y, z_index, @angle)
      else
        @body.draw(@x, @y, z_index)
        @topping && @topping.draw(@x, @y, z_index)
        @decoration && @decoration.draw(@x, @y, z_index)
      end
    end
  end
  
  class Plate
    
    include Actions::ActiveRectangleSubscriber
    attr_accessor :holder
    
    PLATE_LENGTH_AND_WIDTH = 60
    
    def initialize(content)
      @content = content
      @has_cookies = @content.is_a?(CookieOven::Cookies)
    end
    
    def window= shop_window
      @shop_window = shop_window
      @plate_view = Gosu::Image.new(@shop_window.window, 'media/plate.png', false)
      @content.window = shop_window
    end
    
    def update_position(x, y)
      @x = x
      @y = y
      @content.update_position(x, y)
    end
    
    def render(z_index = zindex)
      @plate_view.draw(@x, @y, z_index)
      @content.render(z_index + 0.1)
    end
    
    def handle event
      @shop_window.baker.walk_down_and_trigger(event.x, event.y, :jump_into_bakers_hands, self)
    end
    
    def jump_into_bakers_hands baker
      @holder.give_plate_to(baker) && @holder = nil
    end
    
    def cake
      has_cookies? && raise("this plate has cookies.... not cake.")
      content
    end
    
    def content
      @content
    end
    
    def has_cookies?
      @has_cookies
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
    ACTIVE_RECT_SPAN = 28
    
    include Actions::ActiveRectangleSubscriber
    def initialize(oven, base_x, base_y, name_identifier, place)
      @x = base_x + place[:x_off]
      @y = base_y + place[:y_off]
      @oven = oven
      @cake_name = name_identifier
      @body = Gosu::Image.new(@oven.shop_window.window, "media/#{name_identifier}_button.png", true)
    end
    
    def handle(event)
      @oven.shop_window.baker.walk_down_and_trigger(event.x, event.y, :trigger_to_start_baking, self)
    end
    
    def trigger_to_start_baking *ignore
      @oven.bake(Cake.new(@cake_name)) unless @oven.baking?
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
  
  PROCESS_RUNNER_OFFSET = {:x => 57, :y => 5}
  BAKED_CAKE_PLATE_OFFSET = {:x => 52, :y => 80}
  
  BUTTON_OFFSETS = [{:x_off => 22, :y_off => 32}, {:x_off => 48, :y_off => 49}, {:x_off => 87, :y_off => 49}, {:x_off => 113, :y_off => 32}]
  BUTTON_KLASS = Button
  
  include AliveAsset
  
  COST = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'returns.yml'))[:cake]
  
  def initialize context_oven_data
    @context_oven_data = context_oven_data
    @x, @y = @context_oven_data[:x], @context_oven_data[:y]
    @cake_plate_pos_anim = Util::PositionAnimation.new({:x => @x, :y => @y}, {:x => @x, :y => @y-80}, 40, true, {49 => :put_baked_cake, 99 => :make_plate_pickable}, self)
    @baking_process = Util::ProcessRunner.new(10, @x + PROCESS_RUNNER_OFFSET[:x], @y + PROCESS_RUNNER_OFFSET[:y], :eject_baked_cake, self)
  end
  
  def window= shop_window
    @shop_window = shop_window
    @cake_holder = Gosu::Image.new(@shop_window.window, @context_oven_data[:images][:cake_holder], true)
    @trash_can = Gosu::Image.new(@shop_window.window, @context_oven_data[:images][:trash_can], true)
    @oven_machine_view = Gosu::Image.new(@shop_window.window, @context_oven_data[:images][:machine_view], true)
    @baking_process.window = @shop_window.window
    @context_oven_data[:buttons].each_with_index do |button, index|
      @shop_window.register self.class.const_get('BUTTON_KLASS').new(self, @x, @y, button, self.class.const_get('BUTTON_OFFSETS')[index])
    end
    @plate && @plate.window = @shop_window
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
    @plate = Plate.new(@cake)
    @plate.window = shop_window
    @plate.holder = self
  end
  
  def make_plate_pickable *ignore
    shop_window.register @plate
  end
  
  private
  def render_cake_holder
    args = @cake_plate_pos_anim.hop
    @cake_holder.draw(@cake_tray_x, @cake_tray_y, ZOrder::OVEN_CAKE_HOLDER)
    @plate && @plate.render
  end
end
