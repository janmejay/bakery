require 'markers'
require 'common/one_cake_holder'
require 'zorder'
require 'cursor'
require 'table'
require 'oven'
require 'baker'
require 'dustbin'
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
require 'info_pane'

class Shop < BakeryWizard::Window
  class MoneyBag
    module Precision
      def self.induced_from(amount)
        (amount*100).round.to_f/100
      end
    end
    
    attr_reader :money
    
    def initialize
      @money = 0
    end
    
    def deposit amount
      @money += amount
      enforce_precision!
    end
    
    def withdraw amount
      @money -= amount
      enforce_precision!
    end
    
    def merge_into another_money_bag
      another_money_bag.money += @money
    end
    
    private
    attr_writer :money
    
    def enforce_precision!
      @money = @money.prec(Precision)
    end
  end
  
  module PriceCalculator
    MAX_PROFIT_MARGIN = 0.25
    def self.cost_price_for item
      item.selling_price*(1 - MAX_PROFIT_MARGIN*rand(0)).prec(MoneyBag::Precision)
    end
  end
  
  
  attr_reader :baker, :level, :money_drawer, :bank_account, :dustbin
  include Actions
  include Publisher
  include Subscriber
  
  SUCCESS_MESSAGE_OFFSET = {:x => 255, :y => 290}
  FAILURE_MESSAGE_OFFSET = {:x => 211, :y => 330}
  
  RETRY_BOX_OFFSET = {:x => 312, :y => 324}
  RETRY_BUTTON_OFFSET = {:x => RETRY_BOX_OFFSET[:x] + 26, :y => RETRY_BOX_OFFSET[:y] + 11}
  MENU_BUTTON_OFFSET = {:x => RETRY_BOX_OFFSET[:x] + 26, :y => RETRY_BOX_OFFSET[:y] + 65}
  
  def initialize context
    self.level_context = context
    @assets = []
    register self
    register @dustbin = Dustbin.new(context[:dustbin])
    @renderables = Set.new
    @dead_entities = []
    @dead_entities << Cursor.new
    @dead_entities << Table.new
    @alive_entities = []
    @alive_entities << InfoPane.new(self)
    @no_ui_entities = []
    @alive_entities << @baker = Baker.new(context)
    @context[:assets].each { |asset_data| add_asset(asset_data) }
    @show_message_upto = Time.now
    @unaccounted_for_plates = Set.new
  end
  
  def has_tv?
    @dead_entities.find {|asset| asset.kind_of?(Television) }
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
  
  def window= window
    @window = window
    @background_image = Gosu::Image.new(self.window, @level.bg_image, true)
    @success_message = Gosu::Image.new(self.window, res('media/bakers_goal_achieved.png'))
    @failure_message = Gosu::Image.new(self.window, res('media/baker_failed.png'))
    @font = Gosu::Font.new(self.window, res('media/hand.ttf'), 35)
    for_each_subscriber { |subscriber| subscriber.window = self unless subscriber == self }
    TextButton.new(self, {:x => 22, :y => 10, :z => ZOrder::MODAL_BUTTONS, :dx => 117, :dy => 37}, :menu, @font).activate
    @dead_entities.each { |entity| entity.window = self }
    @alive_entities.each { |entity| entity.window = self }
    @no_ui_entities.each { |entity| entity.window = self }
    reset_flow_control_flags
  end
  
  def ready_for_update_and_render
    @level.window = self
    dump_shop
  end
  
  def menu
    dump_shop && $wizard.go_to(WelcomeMenu)
  end

  def unaccounted_for plate
    $logger.debug("Identified plate #{plate.object_id} as unaccounted.")
    @unaccounted_for_plates << plate
  end

  def accounted_for plate
    @unaccounted_for_plates.delete(plate)
    $logger.debug("Removed plate #{plate.object_id} from unaccounted list. Now unaccounted for list has #{@unaccounted_for_plates.map { |p| p.object_id }.inspect}.")
  end

  def update
    case true
    when button_down?(Gosu::Button::MsLeft): publish(Event.new(:left_click, mouse_x, mouse_y))
    when button_down?(Gosu::Button::MsRight): publish(Event.new(:right_click, mouse_x, mouse_y))
    when button_down?(Gosu::Button::KbEscape): menu
    end
    @alive_entities.each {|entity| entity.update}
    for_each_subscriber {|subscriber| subscriber.perform_updates}
    @level.update
    display_appropriate_result_message
    terminate_once_message_displayed
  end
  
  def level_context= context
    @context = context
    @level = Level.new(@context)
    prepare_money_bags
  end
  
  def warehouse_context= *ignore
    @context.delete(:newly_shipped).each do |asset_id, asset_data|
      @context[:has_asset_ids] << asset_id
      @context[:assets] << asset_data
      add_live_asset(asset_data)
    end
  end
  
  def dump_shop to_file = Util.last_played_file_name(@context)
    @money_drawer.merge_into(@bank_account)
    @context[:money] = @bank_account.money
    block_given? && yield
    execute_ignoring_non_serializable_associations do
      File.open(to_file, "w") do |handle|
        handle.write(Marshal.dump(self))
      end
    end
  end

  def draw
    @dead_entities.each {|entity| entity.draw}
    @alive_entities.each {|entity| entity.draw}
    for_each_subscriber { |subscriber| subscriber.render}
    @renderables.each { |renderable| @renderables.delete(renderable) unless renderable.render }
    @level.draw
    show_game_message_if_needed
    @show_retry_box && @show_retry_box.draw(RETRY_BOX_OFFSET[:x], RETRY_BOX_OFFSET[:y], ZOrder::MODAL_PANES)
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

  def dump_shop_for_retry
    dump_shop Util.last_played_level_file_name(@context) do
      @retry_context = @context
    end
  end
  
  private

  def reset_flow_control_flags
    @flow_control_flags = {}
  end

  def flow_control_flag key, value = nil
    value.nil? || (@flow_control_flags[key] = value)
    @flow_control_flags[key]
  end
  
  def prepare_money_bags
    @money_drawer, @bank_account = MoneyBag.new, MoneyBag.new
    $logger.debug("created a new bank_account with balance => #{@bank_account.money}, will load it with #{@context[:money]}")
    @bank_account.deposit @context[:money]
  end
  
  def display_result succcess
    flow_control_flag(:showing_message) || set_message_time
    flow_control_flag(:showing_message, true)
    if succcess
      @result_slide = @success_message
      play_success_sound
    else
      @result_slide = @failure_message
      play_failure_sound
    end
    @level.clear_remaining_customers!
  end
  
  def display_appropriate_result_message
    flow_control_flag(:showing_message) && return
    unless @level.required_earning_surpassed?
      @level.out_of_customers? && display_result(false)
      return
    end
    display_result(true)
  end

  def reset_and_redisplay_appropriate_message_if_unsold_cakes_matter
    earning_target_status = @level.required_earning_surpassed?
    $logger.debug("Level -> #{@context[:level]} required earning status before accounting for unsold cakes.... #{earning_target_status}")
    account_for_unsold_cakes
    if (@level.required_earning_surpassed? != earning_target_status)
      $logger.debug("Level -> #{@context[:level]} required minimum earning status changed....")
      flow_control_flag(:showing_message, false)
      display_appropriate_result_message
    end
  end

  def account_for_unsold_cakes
    $logger.debug("Level -> #{@context[:level]} accounting for #{@unaccounted_for_plates.length} unsold cakes....")
    @unaccounted_for_plates.each do |accountable_plate|
      accountable_plate.holder.give_plate_to(dustbin)
    end
    $logger.debug("Level -> #{@context[:level]} Paid up for unsold cakes...")
    @unaccounted_for_plates = Set.new
  end
  
  def terminate_once_message_displayed
    flow_control_flag(:termination_done) && return
    ((Time.now > @show_message_upto) && @level.out_of_customers?) || return
    reset_and_redisplay_appropriate_message_if_unsold_cakes_matter
    flow_control_flag(:termination_done, true)
    if @level.required_earning_surpassed?
      go_to_the_next_lvl
      return
    end
    show_retry_option
  end

  def go_to_the_next_lvl
    dump_shop_for_retry
    dump_shop
    $wizard.go_to(StoryPlayer, :pre_params => {:current_context => @context.merge(:level => @context[:level] + 1)})
  end
  
  def show_retry_option
    @show_retry_box && return
    @show_retry_box = Gosu::Image.new(window, res('media/modal_box.png'))
    @retry_level_button = TextButton.new(self, {:x => RETRY_BUTTON_OFFSET[:x], :y => RETRY_BUTTON_OFFSET[:y], :z => ZOrder::MODAL_BUTTONS, :dx => 348, :dy => 44, :image => :game_loader}, :retry_level, @font).activate
    @show_main_menu_button = TextButton.new(self, {:x => MENU_BUTTON_OFFSET[:x], :y => MENU_BUTTON_OFFSET[:y], :z => ZOrder::MODAL_BUTTONS, :dx => 348, :dy => 44, :image => :game_loader}, :go_to_main_menu, @font).activate
  end
  
  def retry_level
    file = Util.last_played_level_file_name(@context)
    @level.first? && $wizard.go_to(Shop, :from_file => file) && return
    context = @retry_context.merge(:level => @retry_context[:level] + 1)
    $wizard.go_to(Warehouse, :pre_params => {:level_context => context}, :params => {:load_from_file => file})
  end
  
  def go_to_main_menu
    $wizard.go_to(WelcomeMenu)
  end
  
  def set_message_time
    @show_message_upto = (Time.now + 5)
  end
  
  def show_game_message_if_needed
    (@show_message_upto < Time.now) && return
    @result_slide.draw(SUCCESS_MESSAGE_OFFSET[:x], SUCCESS_MESSAGE_OFFSET[:y], ZOrder::MESSAGES)
  end
  
  def class_for class_name
    self.class.module_eval("::#{class_name}", __FILE__, __LINE__)
  end

  def play_success_sound
    flow_control_flag(:success_message_played) || Gosu::Sample.new(window, res('media/applause_sound.ogg')).play
    flow_control_flag(:success_message_played, true)
  end

  def play_failure_sound
    flow_control_flag(:failure_message_played) || Gosu::Sample.new(window, res('media/boo_sound.ogg')).play
    flow_control_flag(:failure_message_played, true)
  end

  def execute_ignoring_non_serializable_associations
    to_be_unregistered = []
    removed_renderables = @renderables
    for_each_subscriber { |subscriber| subscriber.kind_of?(Button) && (to_be_unregistered << subscriber) }
    for_each_subscriber { |subscriber| subscriber.kind_of?(Oven::Button) && (to_be_unregistered << subscriber) }
    unregister *to_be_unregistered
    @renderables = []
    yield
    register *to_be_unregistered
    @renderables = removed_renderables
  end
end
