class CookieOven
  
  class Cookies
    def initialize cookies_name
      @cookies_name = cookies_name
    end
    
    def window= shop_window
      @shop_window = shop_window
      @body = Gosu::Image.new(@shop_window.window, res("media/#{@cookies_name}.png"))
    end
    
    def update_position(x, y, angle = nil)
      @x = x
      @y = y
      @angle = angle
    end
    
    def == other
      (self.class == other.class) &&
      (@cookies_name == other.instance_variable_get('@cookies_name'))
    end
    
    def description
      [@cookies_name.to_s.gsub(/_/, ' ').capitalize]
    end
    
    def selling_price
      CookieOven::COST
    end
    
    def render(z_index = ZOrder::CAKE)
      @angle ? @body.draw_rot(@x, @y, z_index, @angle) : @body.draw(@x, @y, z_index)
    end
  end

  include AliveAsset
  include Oven::Plate::Handler::Giver
  
  COST = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'returns.yml'))[:cookies]
  
  BASE_Z_INDEX = ZOrder::TABLE_MOUNTED_EQUIPMENTS
  PLATE_Z_INDEX = BASE_Z_INDEX + 0.1
  COOKIE_Z_INDEX = PLATE_Z_INDEX + 0.1 #no one uses this.. but it gets used implicitly...(by plates z index allocation to cake)
  HOOD_Z_INDEX = COOKIE_Z_INDEX + 0.1
  BODY_Z_INDEX = HOOD_Z_INDEX + 0.1
  
  BUTTON_OFFSETS = [{:x => 3, :y => 32}, {:x => 109, :y => 32}]
  
  PLATE_OFFSET = {:x => 40, :y => 10}
  
  PROCESS_RUNNER_OFFSET = {:x => 45, :y => 27}

  def initialize context_cookie_oven_data
    @context_cookie_oven_data = context_cookie_oven_data
    @x, @y = context_cookie_oven_data[:x], context_cookie_oven_data[:y]
    @baking_process = Util::ProcessRunner.new(10, @x + PROCESS_RUNNER_OFFSET[:x], @y + PROCESS_RUNNER_OFFSET[:y], :make_cookies_available_when_baked, self)
    drop_hood(false)
  end
  
  def window= shop_window
    @shop_window = shop_window
    @baking_process.window = @shop_window.window
    @body = Gosu::Image.new(@shop_window.window, res(@context_cookie_oven_data[:machine_view]), true)
    @base = Gosu::Image.new(@shop_window.window, res(@context_cookie_oven_data[:machine_base]), true)
    @hood = Gosu::Image.new(@shop_window.window, res(@context_cookie_oven_data[:machine_hood]), true)
    (@cookie_names = @context_cookie_oven_data[:buttons]).each_with_index do |button, index|
      GameButton.new(self, {:x => @x + BUTTON_OFFSETS[index][:x], :y => @y + BUTTON_OFFSETS[index][:y], 
        :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 28, :dy => 28}, button).activate
    end
    @hood_lift_sound = Gosu::Sample.new(@shop_window.window, res('media/cookie_oven_hood_lift.ogg'))
    @hood_drop_sound = Gosu::Sample.new(@shop_window.window, res('media/cookie_oven_hood_drop.ogg'))
    @plate && @plate.window = @shop_window
    @baking_process.attach_sound(Gosu::Song.new(@shop_window.window, res('media/cookie_oven_sound.ogg')))
  end
  
  def build_sample_on *ignore
    plate = Oven::AbstractPlate.new(Cookies.new(@cookie_names[rand(@cookie_names.length)]))
    plate.window = window
    plate
  end
  
  def brown_cookies *ignore
    bake(:brown_cookies)
  end
  
  def white_cookies *ignore
    bake(:white_cookies)
  end
  
  def update
    @plate && @plate.update_position(@x + PLATE_OFFSET[:x], @y + PLATE_OFFSET[:y])
    @baking_process.update
  end
  
  def make_cookies_available_when_baked *ignore
    @shop_window.register(@plate)
    lift_hood
  end

  def after_giving_plate *ignore
    drop_hood
  end
  
  def window
    @shop_window
  end
  
  def draw
    @body.draw(@x, @y, BODY_Z_INDEX)
    @show_hood && @hood.draw(@x, @y, HOOD_Z_INDEX)
    @base.draw(@x, @y, BASE_Z_INDEX)
    @baking_process.render
    @plate && @plate.render(PLATE_Z_INDEX)
  end
  
  private
  
  def lift_hood
    @hood_lift_sound.play
    @show_hood = false
  end
  
  def already_baking?
    @baking_process.running?
  end
  
  def bake cookies_named
    already_baking? && return
    @plate && give_plate_to(@shop_window.dustbin)
    drop_hood
    @baking_process.start
    @plate = Oven::Plate.new(Cookies.new(cookies_named))
    @plate.window = window
    @plate.holder = self
  end
  
  def drop_hood play_sound = true
    play_sound && @hood_drop_sound.play
    @show_hood = true
  end
end
