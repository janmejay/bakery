class TextField < Gosu::TextInput
  
  PADDING = 5
  
  attr_reader :x, :y
  
  def initialize(window, font, x, y, default_text = 'Some Text', approx_max_allowed_length = 12, color_options = {:inactive_color  => 0xcc666666,
                                                                                                                  :active_color    => 0xaaaaaaaa,
                                                                                                                  :selection_color => 0xcc0000ff,
                                                                                                                  :caret_color     => 0xffcccccc})
    super()
    @window, @font, @x, @y = window, font, x, y
    self.text = default_text
    @width = @font.text_width('W'*approx_max_allowed_length)
    @color_options = color_options
  end
  
  def draw
    if @window.text_input == self then
      background_color = @color_options[:active_color]
    else
      background_color = @color_options[:inactive_color]
    end
    @window.draw_quad(x - PADDING,         y - PADDING,          background_color,
                      x + width + PADDING, y - PADDING,          background_color,
                      x - PADDING,         y + height + PADDING, background_color,
                      x + width + PADDING, y + height + PADDING, background_color, 0)
    
    pos_x = x + @font.text_width(self.text[0...self.caret_pos])
    sel_x = x + @font.text_width(self.text[0...self.selection_start])
    
    @window.draw_quad(sel_x, y,          @color_options[:selection_color],
                      pos_x, y,          @color_options[:selection_color],
                      sel_x, y + height, @color_options[:selection_color],
                      pos_x, y + height, @color_options[:selection_color], 0)

    if @window.text_input == self then
      @window.draw_line(pos_x, y,          @color_options[:caret_color],
                        pos_x, y + height, @color_options[:caret_color], 0) unless Time.now.sec & 1 == 0
    end
    @font.draw(self.text, x, y, 0, 1.0, 1.0, @color_options[:caret_color])
  end
  
  def update
    loop do
      (@font.text_width(self.text) < @width) && break
      self.text = self.text[0..-2]
    end if text
  end

  def width
    @width
  end
  
  def height
    @font.height
  end

  def under_point?(mouse_x, mouse_y)
    mouse_x > x - PADDING and mouse_x < x + width + PADDING and
      mouse_y > y - PADDING and mouse_y < y + height + PADDING
  end
end