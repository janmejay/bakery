require 'cursor'
require 'util/actions'
require 'common/text_field'
require 'common/title'
require 'common/action_message'
require 'yaml'
require File.join(File.dirname(__FILE__), "common", "text_button")
require 'fileutils'

class SaveLoad < BakeryWizard::Window
  include Actions
  include Publisher
  include Subscriber
  
  WIDTH, HEIGHT = 420, 768
  
  V_PAD = 20
  V_SPAN = 44
  
  ACTION_MESSAGE_OFFSET = REL :x => WIDTH/2, :y => 40
  MESSAGE_OFFSET = REL :x => 40, :y => 40 + V_SPAN + V_PAD
  TEXT_FIELD_OFFSET = MESSAGE_OFFSET.merge(:x => MESSAGE_OFFSET[:x] + 80)
  MESSAGE_COLOR = 0xff222222
  FILE_LISTING_OFFSET = MESSAGE_OFFSET.merge(:y => MESSAGE_OFFSET[:y] + 130, :x => MESSAGE_OFFSET[:x] - 180)
  LOAD_BUTTON_OFFSET = FILE_LISTING_OFFSET.merge(:x => FILE_LISTING_OFFSET[:x] + 360)
  SAVE_BUTTON_OFFSET = FILE_LISTING_OFFSET.merge(:x => LOAD_BUTTON_OFFSET[:x] + 120)
  DELETE_BUTTON_OFFSET = FILE_LISTING_OFFSET.merge(:x => SAVE_BUTTON_OFFSET[:x] + 120)
  
  MAX_FILES_HONORED = 8
  
  MAIN_SAVE_BUTTON_OFFSET = {:x => 160, :y => MESSAGE_OFFSET[:y] + V_SPAN + V_PAD}
  BACK_BUTTON_OFFSET = {:x => 513, :y => MESSAGE_OFFSET[:y] + V_SPAN + V_PAD}
  BG_OFFSET = REL :x => 0, :y => 84
  
  def initialize context
    @context = context
    @cursor = Cursor.new
  end
  
  def window= window
    @window = window
    @cursor.window = self
    @background = Gosu::Image.new(self.window, 'media/game_loader_bg.png', false)
    @print_font = Gosu::Font.new(self.window, 'media/hand.ttf', 35)
    @action_message = ActionMessage.new(@print_font, ACTION_MESSAGE_OFFSET[:x], ACTION_MESSAGE_OFFSET[:y])
    @new_file_name_field = TextField.new(self, @print_font, TEXT_FIELD_OFFSET[:x], TEXT_FIELD_OFFSET[:y], '', 15, 
      :inactive_color  => 0x00ffffff, :active_color => 0x00ffffff, :selection_color => 0x00ffffff, :caret_color => MESSAGE_COLOR)
    self.text_input = @new_file_name_field
    TextButton.new(self, {:x => MAIN_SAVE_BUTTON_OFFSET[:x], :y => MAIN_SAVE_BUTTON_OFFSET[:y], :z => 1, :dx => 348, 
      :dy => 44, :image => :game_loader}, :save_game, @print_font).activate
    TextButton.new(self, {:x => BACK_BUTTON_OFFSET[:x], :y => BACK_BUTTON_OFFSET[:y], :z => 1, :dx => 348, 
      :dy => 44, :image => :game_loader}, :go_back, @print_font).activate
    list_loadables
  end
  
  def list_loadables
    @saved_game_names = Dir.entries(Util.saved_games_dir_name(@context))
    @saved_game_names.delete '.'
    @saved_game_names.delete '..'
    @saved_game_names = @saved_game_names[0...MAX_FILES_HONORED]
    @load_save_buttons ||= []
    @load_save_buttons.map { |button| button.deactivate }
    @load_save_buttons = []
    @saved_game_names.each_with_index do |name, index|
      dy = index*(V_PAD + V_SPAN)
      save_button = TextButton.new(self, {:x => SAVE_BUTTON_OFFSET[:x], :y => SAVE_BUTTON_OFFSET[:y] + dy, :z => 1, :dx => 96, :dy => 44, 
        :image => :game_loader_small}, :save, @print_font) { save_game name }
      save_button.activate
      load_button = TextButton.new(self, {:x => LOAD_BUTTON_OFFSET[:x], :y => LOAD_BUTTON_OFFSET[:y] + dy, :z => 1, :dx => 96, :dy => 44, 
        :image => :game_loader_small}, :load, @print_font) { load_game name }
      load_button.activate
      delete_button = TextButton.new(self, {:x => DELETE_BUTTON_OFFSET[:x], :y => DELETE_BUTTON_OFFSET[:y] + dy, :z => 1, :dx => 96, :dy => 44, 
        :image => :game_loader_small}, :delete, @print_font) { delete_game name }
      delete_button.activate
      @load_save_buttons << save_button
      @load_save_buttons << load_button
      @load_save_buttons << delete_button
    end
  end
  
  def save_game to_file = nil
    to_file.nil? && (@saved_game_names.length >= MAX_FILES_HONORED) && 
      (@action_message.message("You can't save more files, please overwrite on an existing file.", ActionMessage::NEGETIVE_MESSAGE_COLOR)) && return
    FileUtils.mkdir_p dir_path = Util.saved_games_dir_name(@context)
    FileUtils.cp Util.last_played_file_name(@context), File.join(dir_path, to_file || file_name_requested)
    list_loadables
    @action_message.message "The game has been saved."
  end
  
  def load_game from_file
    $wizard.go_to Shop, {:from_file => File.join(Util.saved_games_dir_name(@context), from_file)}
  end
  
  def file_name_requested
    @new_file_name_field.text.empty? ? "saved_game@#{Time.now.strftime('%m-%d-%y(%H:%M)')}" : @new_file_name_field.text.gsub('/', '_')
  end
  
  def delete_game from_file
    FileUtils.rm_rf File.join(Util.saved_games_dir_name(@context), from_file)
    list_loadables
    @action_message.message "Save file '#{from_file}' deleted."
  end
  
  def go_back
    $wizard.go_to WelcomeMenu
  end
  
  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
    @new_file_name_field.update
  end
  
  def draw
    @background.draw(BG_OFFSET[:x], BG_OFFSET[:y], 0)
    @cursor.draw
    for_each_subscriber { |subscriber| subscriber.render }
    @print_font.draw('Save as: ', MESSAGE_OFFSET[:x], MESSAGE_OFFSET[:y], 0, 1.0, 1.0, MESSAGE_COLOR)
    @new_file_name_field.draw
    @saved_game_names.each_with_index do |name, index| 
      @print_font.draw(name, FILE_LISTING_OFFSET[:x], FILE_LISTING_OFFSET[:y] + index*(V_SPAN + V_PAD), 0, 1.0, 1.0, MESSAGE_COLOR)
    end
    @action_message.draw
  end
end