require 'markers'
require 'zorder'
require 'cursor'
require 'baker'
require 'table'
require 'dustbin'
require 'oven'
require 'topping_oven'
require 'cookie_oven'
require 'shoe'
require 'television'
require 'froster'
require 'showcase'
require 'decorator'
require 'util/actions'
require 'util/process_runner'
require File.join(File.dirname(__FILE__), "common", "game_button")
require 'set'
require 'order_builder'
require 'level'

class Shop < BakeryWizard::Window
  attr_reader :baker
  include Actions
  include Publisher
  include Subscriber
  
  SUCCESS_MESSAGE_OFFSET = {:x => 255, :y => 290}
  FAILURE_MESSAGE_OFFSET = {:x => 211, :y => 330}
  
  def initialize context
    @context = context
    @assets = []
    register self
    register Dustbin.new(context[:dustbin])
    @renderables = Set.new
    @dead_entities = []
    @dead_entities << Cursor.new
    @dead_entities << Table.new(context[:table])
    @alive_entities = []
    @no_ui_entities = []
    @alive_entities << @baker = Baker.new(context)
    @context[:assets].each { |asset_data| add_asset(asset_data) }
    @level = Level.new(@context)
    @show_message_upto = Time.now
  end
  
  def assets
    @assets
  end
  
  def add_asset asset_data
    asset = class_for(asset_data[:class]).new(asset_data)
    asset.is_a?(AliveAsset) && @alive_entities << asset
    asset.is_a?(DeadAsset) && @dead_entities << asset
    asset.is_a?(Subscriber) && register(asset)
    asset.is_a?(NoUiAsset) && @no_ui_entities << asset
    @assets << asset
    asset
  end
  
  def add_live_asset asset_data
    asset = add_asset(asset_data)
    asset.window = self
  end
  
  def deactivate_all_buttons
    to_be_unregistered = []
    for_each_subscriber { |subscriber| subscriber.kind_of?(Button) && (to_be_unregistered << subscriber) }
    for_each_subscriber { |subscriber| subscriber.kind_of?(Oven::Button) && (to_be_unregistered << subscriber) }
    unregister *to_be_unregistered
  end
  
  def window= window
    @window = window
    @background_image = Gosu::Image.new(self.window, @context[:floor_view], true)
    @success_message = Gosu::Image.new(self.window, 'media/bakers_goal_achived.png')
    @failure_message = Gosu::Image.new(self.window, 'media/baker_failed.png')
    for_each_subscriber { |subscriber| subscriber.window = self unless subscriber == self }
    @dead_entities.each { |entity| entity.window = self }
    @alive_entities.each { |entity| entity.window = self }
    @no_ui_entities.each { |entity| entity.window = self }
  end
  
  def ready_for_update_and_render
    @level.window = self
  end

  def update
    case true
    when button_down?(Gosu::Button::MsLeft): publish(Event.new(:left_click, mouse_x, mouse_y))
    when button_down?(Gosu::Button::MsRight): publish(Event.new(:right_click, mouse_x, mouse_y))
    when button_down?(Gosu::Button::KbEscape):
      deactivate_all_buttons
      dump_shop && $wizard.go_to(WelcomeMenu)
    #HACK: this is a hack(under this comment)... this will go away once the story thing is in....
    when button_down?(Gosu::Button::KbTab):
      deactivate_all_buttons
      dump_shop && $wizard.go_to(Warehouse, :params => {:shop_context => @context})
    end
    @alive_entities.each {|entity| entity.update}
    for_each_subscriber {|subscriber| subscriber.perform_updates}
    @level.update
    @level.required_earning_surpassed? ? display_success_result : (@level.out_of_customers? && display_failure_result)
  end
  
  def warehouse_context= context
    @context = context
    @context.delete(:newly_shipped).each do |asset_id, asset_data|
      @context[:has_asset_ids] << asset_id
      @context[:assets] << asset_data
      add_live_asset(asset_data)
    end
  end
  
  def dump_shop
    File.open(Util.last_played_file_name(@context), "w") do |handle|
      handle.write(Marshal.dump(self))
    end
  end

  def draw
    @dead_entities.each {|entity| entity.draw}
    @alive_entities.each {|entity| entity.draw}
    for_each_subscriber { |subscriber| subscriber.render}
    @renderables.each { |renderable| @renderables.delete(renderable) unless renderable.render }
    @level.draw
    show_game_message_if_needed
  end
  
  def render
    @background_image.draw(0, 0, zindex)
  end
  
  def can_consume?(event)
    event.propagatable
  end
  
  def handle(e)
    @baker.walk_down_and_trigger e.x, e.y
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
  
  def keep_rendering_until_returns_nil renderable
    @renderables << renderable
  end
  
  def zindex
    ZOrder::BACKGROUND
  end
  
  private
  
  def display_success_result
    set_message_time
    @show_success_message = true
  end
  
  def display_failure_result
    set_message_time
    @show_failure_message = true
  end
  
  def set_message_time
    @show_message_upto = (Time.now + 10)
  end
  
  def show_game_message_if_needed
    (@show_message_upto < Time.now) && return
    @show_success_message && @success_message.draw(SUCCESS_MESSAGE_OFFSET[:x], SUCCESS_MESSAGE_OFFSET[:y], ZOrder::MESSAGES)
    @show_failure_message && @failure_message.draw(FAILURE_MESSAGE_OFFSET[:x], FAILURE_MESSAGE_OFFSET[:y], ZOrder::MESSAGES)
  end
  
  def class_for class_name
    self.class.module_eval("::#{class_name}", __FILE__, __LINE__)
  end
end