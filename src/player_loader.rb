require 'cursor'
require 'common/text_field'
require 'common/title'
require 'common/text_button'

class PlayerLoader < BakeryWizard::Window
  include Actions
  include Publisher
  include Subscriber
  
  WIDTH, HEIGHT = 420, 320
  TITLE_OFFSET = REL :x => 565, :y => -210
  MESSAGE_OFFSET = REL :x => 0, :y => 360
  TEXT_FIELD_OFFSET = MESSAGE_OFFSET.merge(:x => MESSAGE_OFFSET[:x] + 220)
  IMAGE_OFFSET = REL :x => 50, :y => 0
  BUTTON_OFFSET = REL :x => 397, :y => 318
  MESSAGE_COLOR = 0xff222222
  def initialize context, window
    super(window)
    @context = context
    @cake_image = Gosu::Image.new(self.window, 'media/loading-cake.png', false)
    @cursor = Cursor.new(self)
    @print_font = Gosu::Font.new(self.window, 'media/hand.ttf', 40)
    @name_field = TextField.new(self, @print_font, TEXT_FIELD_OFFSET[:x], TEXT_FIELD_OFFSET[:y], 'Sweta', 9, 
      :inactive_color  => 0x00ffffff, :active_color => 0x00ffffff, :selection_color => 0x00ffffff, :caret_color => MESSAGE_COLOR)
    @title = Title.new(self, 80, TITLE_OFFSET[:x], TITLE_OFFSET[:y])
    self.text_input = @name_field
    @get_baking_button = TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y], :z => 1, :dx => 120, :dy => 120}, :get_baking, @print_font)
    @get_baking_button.activate
  end
  
  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
    @name_field.update
  end
  
  def get_baking
    @name_field.text.empty? || (@context[:name] = @name_field.text) && $wizard.next 
  end
  
  def draw
    @cake_image.draw(IMAGE_OFFSET[:x], IMAGE_OFFSET[:y], 0)
    @print_font.draw('Who is the baker???', MESSAGE_OFFSET[:x], MESSAGE_OFFSET[:y], 0, 1.0, 1.0, MESSAGE_COLOR)
    @cursor.draw
    @get_baking_button.render
    @name_field.draw
    @title.draw
  end
end