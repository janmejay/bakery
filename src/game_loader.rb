require 'cursor'
require 'common/text_field'

class GameLoader < Gosu::Window
  WIDTH, HEIGHT = 320, 320
  TEXT_FIELD_OFFSET = {:x => 40, :y => 40}
  def initialize context
    @context = context
    super(WIDTH, HEIGHT, false)
    self.caption = "Bakery"
    @cake_image = Gosu::Image.new(self, 'media/loading-cake.png', false)
    @cursor = Cursor.new(self)
    @name_field = TextField.new(self, Gosu::Font.new(self, Gosu::default_font_name, 20), TEXT_FIELD_OFFSET[:x], TEXT_FIELD_OFFSET[:y], 'Sweta')
    self.text_input = @name_field
  end
  
  def update
    @name_field.update
  end
  
  def draw
    draw_quad(0, 0, 0xffffffff, WIDTH, 0, 0xffffffff, 0, HEIGHT, 0xffffffff, WIDTH, HEIGHT, 0xffffffff)
    @cake_image.draw(0, 0, 0)
    @cursor.draw
    @name_field.draw
  end
end