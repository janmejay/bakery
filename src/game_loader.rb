require 'cursor'
require 'util/actions'
require 'common/text_field'
require 'common/title'
require File.join(File.dirname(__FILE__), "common", "text_button")

class GameLoader < Gosu::Window
  include Actions
  include Publisher
  include Subscriber
  
  WIDTH, HEIGHT = 420, 600
  
  BUTTON_OFFSET = {:x => 36, :y => 40}
  
  def initialize context
    super(WIDTH, HEIGHT, false)
    @context = context
    self.caption = "Bakery"
    @cursor = Cursor.new(self)
    @background = Gosu::Image.new(self, 'media/game_loader_bg.png', false)
    font = Gosu::Font.new(self, 'media/hand.ttf', 35)
    @buttons = []
    @buttons << TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y], :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :new_game, font)
    @buttons << TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + (44 + 20), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :load_game, font)
    @buttons << TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + 2*(44 + 20), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :exit, font)
    @buttons.each do |button|
      button.activate
    end
  end
  
  def window
    self
  end
  
  def new_game
    puts "New Game Requested"
    $wizard.next
  end
  
  def load_game
    puts "Load Game Requested"
  end
  
  def exit
    puts "Exit Requested"
  end
  
  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
  end
  
  def draw
    draw_quad(0, 0, 0xffffffff, WIDTH, 0, 0xffffffff, 0, HEIGHT, 0xffffffff, WIDTH, HEIGHT, 0xffffffff)
    @background.draw(0, 0, 0)
    @cursor.draw
    for_each_subscriber { |subscriber| subscriber.render}
  end
end