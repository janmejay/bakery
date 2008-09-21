require 'cursor'
require 'util/actions'
require 'common/text_field'
require 'common/title'
require 'yaml'
require File.join(File.dirname(__FILE__), "common", "text_button")

class WelcomeMenu < BakeryWizard::Window
  include Actions
  include Publisher
  include Subscriber
  
  WIDTH, HEIGHT = 420, 600
  
  BUTTON_OFFSET = REL :x => 36, :y => 40
  BG_OFFSET = REL :x => 0, :y => 0
  
  V_PAD = 20
  V_SPAN = 44
  
  def initialize context
    @context = context
    @cursor = Cursor.new
  end
  
  def window= window
    @window = window
    @cursor.window = self
    @background = Gosu::Image.new(self.window, 'media/game_loader_bg.png', false)
    font = Gosu::Font.new(self.window, 'media/hand.ttf', 35)
    File.exists?(Util.last_played_file_name(@context)) && TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y], :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :resume_game, font).activate
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + (V_PAD + V_SPAN), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :new_game, font).activate
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + 2*(V_PAD + V_SPAN), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :load_or_save_game, font).activate
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + 3*(V_PAD + V_SPAN), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :credits, font).activate
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + 4*(V_PAD + V_SPAN), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :about, font).activate
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + 5*(V_PAD + V_SPAN), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :go_back, font).activate
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y] + 6*(V_PAD + V_SPAN), :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :exit, font).activate
  end
  
  def resume_game
    $wizard.go_to Shop, {:from_file => Util.last_played_file_name(@context)}
  end
  
  def load_or_save_game
    $wizard.go_to SaveLoad
  end
  
  def new_game
    @context.merge!(YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', 'new-game-data.yml')))
    warehouse_catlog = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', 'warehouse-stock.yml'))
    @context[:assets] = []
    @context[:has_asset_ids].each { |asset_id| @context[:assets] << warehouse_catlog[asset_id] }
    $wizard.go_to StoryPlayer
  end
  
  def go_back
    $wizard.go_to PlayerLoader
  end
  
  def credits
    $wizard.go_to Credits
  end
  
  def about
    $wizard.go_to About
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