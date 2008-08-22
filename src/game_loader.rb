require 'cursor'
require 'util/actions'
require 'common/text_field'
require 'common/title'
require File.join(File.dirname(__FILE__), "common", "text_button")

class GameLoader < BakeryWizard::Window
  include Actions
  include Publisher
  include Subscriber
  
  WIDTH, HEIGHT = 420, 600
  
  BUTTON_OFFSET = REL :x => 36, :y => 40
  BG_OFFSET = REL :x => 0, :y => 0
  
  def initialize context, window
    super(window)
    @context = context
    
    @cursor = Cursor.new(self)
    @background = Gosu::Image.new(self.window, 'media/game_loader_bg.png', false)
    font = Gosu::Font.new(self.window, 'media/hand.ttf', 35)
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y], :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :new_game, font).activate
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + (44 + 20), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :load_game, font).activate
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + 2*(44 + 20), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :exit, font).activate
    show
  end
  
  def new_game
    $wizard.next
  end
  
  def load_game
    puts "Load Game Requested"
  end
  
  def exit
    Kernel.exit 0
  end
  
  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
  end
  
  def draw
    @background.draw(BG_OFFSET[:x], BG_OFFSET[:y], 0)
    @cursor.draw
    for_each_subscriber { |subscriber| subscriber.render}
  end
end