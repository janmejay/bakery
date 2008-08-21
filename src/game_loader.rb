require 'cursor'
require 'common/text_field'
require 'common/title'

class GameLoader < Gosu::Window
  WIDTH, HEIGHT = 420, 320
  TITLE_OFFSET = {:x => 292, :y => 3}
  MESSAGE_OFFSET = {:x => 10, :y => 200}
  TEXT_FIELD_OFFSET = MESSAGE_OFFSET.merge(:x => 230)
  IMAGE_OFFSET = {:x => 50, :y => 0}
  BUTTON_OFFSET = {:x => 297, :y => 198}
  BUTTON_MESSAGE_OFFSET = {:x => BUTTON_OFFSET[:x] + 1, :y => BUTTON_OFFSET[:y] + 37}
  MESSAGE_COLOR = 0xff222222
  def initialize context
    @context = context
    super(WIDTH, HEIGHT, false)
    self.caption = "Bakery"
    @cake_image = Gosu::Image.new(self, 'media/loading-cake.png', false)
    @cursor = Cursor.new(self)
    @print_font = Gosu::Font.new(self, 'media/hand.ttf', 40)
    @name_field = TextField.new(self, @print_font, TEXT_FIELD_OFFSET[:x], TEXT_FIELD_OFFSET[:y], 'Sweta', 9, 
      :inactive_color  => 0x00ffffff, :active_color => 0x00ffffff, :selection_color => 0x00ffffff, :caret_color => MESSAGE_COLOR)
    @title = Title.new(self, 70, TITLE_OFFSET[:x], TITLE_OFFSET[:y])
    self.text_input = @name_field
    @get_baking_button = Gosu::Image.new(self, 'media/get_baking_button.png', false)
  end
  
  def update
    @name_field.update
    if button_down? Gosu::Button::MsLeft
      mouse_x > BUTTON_OFFSET[:x] && mouse_y > BUTTON_OFFSET[:y] && capture_player_name && $wizard.next
    end
  end
  
  def capture_player_name
    return @context[:name] = @name_field.text unless @name_field.text.empty?
  end
  
  def draw
    draw_quad(0, 0, 0xffffffff, WIDTH, 0, 0xffffffff, 0, HEIGHT, 0xffffffff, WIDTH, HEIGHT, 0xffffffff)
    @cake_image.draw(IMAGE_OFFSET[:x], IMAGE_OFFSET[:y], 0)
    @print_font.draw('Who is the baker???', MESSAGE_OFFSET[:x], MESSAGE_OFFSET[:y], 0, 1.0, 1.0, MESSAGE_COLOR)
    @cursor.draw
    @get_baking_button.draw(BUTTON_OFFSET[:x], BUTTON_OFFSET[:y], 0)
    @name_field.draw
    @title.draw
    @print_font.draw('Get baking!!!', BUTTON_MESSAGE_OFFSET[:x], BUTTON_MESSAGE_OFFSET[:y], 0, 1.0, 1.0, MESSAGE_COLOR)
  end
end