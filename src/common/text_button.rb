require File.join(File.dirname(__FILE__), 'button')

class TextButton < Button
  def initialize(owner, view_options, callback_name, font, color = 0xffffffff, title = nil, &callback)
    super(owner, view_options, block_given? ? callback : callback_name)
    @font = font
    @title = title || callback_name.to_s.split(/_/).collect {|word| word.capitalize }.join(' ')
    @color = color
  end
  
  def render
    super
    @font.draw(@title, (@dx - @font.text_width(@title))/2 + @x, (@dy - @font.height)/2 + @y, @z, 1.0, 1.0, @color)
  end
end
