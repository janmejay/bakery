class ActionMessage
  
  POSITIVE_MESSAGE_COLOR = 0xff1c6f0c
  NEGETIVE_MESSAGE_COLOR = 0xffff6666
  
  def initialize print_font, about_x, at_y
    @print_font = print_font
    @about_x = about_x
    @at_y = at_y
  end
  
  def message message, color = POSITIVE_MESSAGE_COLOR
    @message = message
    @message_color = color
    @message_x_offset = - @print_font.text_width(@message)/2
  end
  
  def draw(z_index = 0)
    @message && @print_font.draw(@message, @about_x + @message_x_offset, @at_y, z_index, 1.0, 1.0, @message_color)
  end
end