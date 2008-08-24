class Util::FontAnimator
  module ZeroXasY
    def self.x for_y
      0
    end
  end
  
  class Animation
    def initialize(shop_window, text, font, color, slide_sequence, z)
      @shop_window, @text, @font, @slide_sequence, @color, @z = shop_window, text, font, slide_sequence, color, z
    end
    
    def render
      (details = @slide_sequence.shift) && @font.draw(@text, details[:x], details[:y], @z, 1.0, 1.0, "#{details[:alpha]}#{@color}".to_i(16))
      details
    end
  end
  
  def initialize(shop_window, length, options = {})
    @shop_window = shop_window
    font_name = options[:font_name] || Gosu::default_font_name
    font_size = options[:font_size] || 19
    @x, @y, @z = options[:x], options[:y], options[:z]
    @color = options[:color]
    @y_displacement = options[:y_displacement] || -60
    @x_as_y = options[:x_as_y] || ZeroXasY
    @font = Gosu::Font.new(@shop_window.window, font_name, font_size)
    @length = length
  end
  
  def start_anim(text, options = {})
    x, y, z = get(:x, options), get(:y, options), get(:z, options)
    y_displacement = get(:y_displacement, options)
    x_as_y = get(:x_as_y, options)
    coordinates = build_slide_details(y_displacement, x_as_y, x, y)
    @shop_window.keep_rendering_until_returns_nil(Animation.new(@shop_window, text, @font, @color, coordinates, z))
  end
  
  private
  def get(param, prefered_options)
    prefered_options[param] || instance_variable_get("@#{param}")
  end
  
  def build_slide_details y_displacement, x_as_y, x, y
    slide_details = []
    y_velocity = y_displacement.to_f/@length
    alpha_velocity = 255/@length
    @length.times do |index|
      dx = x_as_y.x(dy = y_velocity*(index + 1))
      alpha = 255 - alpha_velocity*index
      slide_details << {:x => (x + dx).to_i, :y => (y + dy).to_i, :alpha => alpha.to_s(16)}
    end
    slide_details
  end
end