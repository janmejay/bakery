# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'
require 'util/position_animation'
require 'util/actions'
require 'util/process_runner'

class Oven
  include Actions::ActiveRectangleSubscriber
  class Cake
    def initialize(oven, image_name)
      @cake_view = Gosu::Image.new(oven.window, image_name)
    end
    
    def update_position(x, y)
      @x = x
      @y = y
    end
    
    def render
      @cake_view.draw(@x, @y, ZOrder::CAKE) 
    end
  end
  
  class Plate
    def initialize(oven, cake)
      @plate_view = Gosu::Image.new(oven.window, 'media/plate.png')
      @cake = cake
    end
    
    def update_position(x, y)
      @x = x
      @y = y
      @cake.update_position(x, y)
    end
    
    def render
      @plate_view.draw(@x, @y, ZOrder::PLATE)
      @cake.render
    end
  end

  class Button
    FIRST, SECOND, THIRD, FOURTH = {:x_off => 27, :y_off => 40}, {:x_off => 60, :y_off => 64}, {:x_off => 106, :y_off => 64}, {:x_off => 138, :y_off => 40}
    
    ACTIVE_RECT_SPAN = 35
    
    include Actions::ActiveRectangleSubscriber
    def initialize(oven, base_x, base_y, name_identifier, place = FIRST)
      @x = base_x + place[:x_off]
      @y = base_y + place[:y_off]
      @oven = oven
      @cake_image_name = "media/#{name_identifier}.png"
      @body = Gosu::Image.new(@oven.window, "media/#{name_identifier}_button.png", true)
    end
    
    def handle(event)
      @oven.window.baker.walk_down_and_trigger(event.x, event.y) do
        @oven.bake(Cake.new(@oven, @cake_image_name)) unless @oven.baking?
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
  
  attr_reader :window
  
  PROCESS_RUNNER_OFFSET = {:x => 75, :y => 15}
  BAKED_CAKE_PLATE_OFFSET = {:x => 70, :y => 110}
  
  def initialize window
    @window = window
    @cake_holder = Gosu::Image.new(@window, 'media/oven_cake_holder.png', true)
    @trash_can = Gosu::Image.new(@window, 'media/oven_dustbin.png', true)
    @oven_machine_view = Gosu::Image.new(@window, 'media/oven_machine.png', true)
    @cake_plate_pos_anim = Util::PositionAnimation.new({:x => 530, :y => 0}, {:x => 530, :y => -100}, 40, true, {0.49 => lambda { put_baked_cake}})
    @baking_process = Util::ProcessRunner.new(@window, 10, 530 + PROCESS_RUNNER_OFFSET[:x], 0 + PROCESS_RUNNER_OFFSET[:y]) { eject_baked_cake }
    window.register Button.new(self, 530, 0, :circular_cake)
    window.register Button.new(self, 530, 0, :rect_cake, Button::SECOND)
    window.register Button.new(self, 530, 0, :triangular_cake, Button::THIRD)
    window.register Button.new(self, 530, 0, :heart_cake, Button::FOURTH)
    perform_updates
  end

  def perform_updates
    @baking_process.update
    @cake_tray_x, @cake_tray_y = @cake_plate_pos_anim.hop
    @plate && @plate.update_position(@cake_tray_x + BAKED_CAKE_PLATE_OFFSET[:x], @cake_tray_y + BAKED_CAKE_PLATE_OFFSET[:y])
  end
  
  def handle(event)
    play_animation
  end

  def render
    @oven_machine_view.draw(530, 0, zindex)
    @trash_can.draw(530, 0, ZOrder::OVEN_TRASH_CAN)
    @baking_process.render
    render_cake_holder
  end
  
  def zindex
    ZOrder::OVEN
  end
  
  def bake(cake)
    @cake = cake
    @baking_process.start unless baking?
  end
  
  def baking?
    @baking_process.running?
  end
  
  def eject_baked_cake
    @cake_plate_pos_anim.reset
  end
  
  def put_baked_cake
    @plate = Plate.new(self, @cake)
  end
  
  protected
  def active_x
    return 550, 715
  end
  
  def active_y
    return 60, 119
  end
  
  private
  def render_cake_holder
    args = @cake_plate_pos_anim.hop
    @cake_holder.draw(@cake_tray_x, @cake_tray_y, ZOrder::OVEN_CAKE_HOLDER)
    @plate && @plate.render
  end
end
