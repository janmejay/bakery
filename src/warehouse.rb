require 'common/action_message'

class Warehouse < BakeryWizard::Window
  include Actions
  include Publisher
  include Subscriber
  
  class Item
    
    THMB_V_PAD = (108 - 80)/2
    THMB_H_PAD = 10
    
    DESC_H_PAD = 100
    DESC_V_PAD_1 = 50
    DESC_V_PAD_2 = 70
    
    BUTTON_X_PAD = 350
    BUTTON_Y_PAD = 10
    
    TITLE_H_PAD = DESC_H_PAD
    TITLE_V_PAD = 16
    
    WIDTH, HEIGHT = 512, 108
    
    def self.set_counter_for_item_positioning
      @@count = 0
    end
    
    def initialize warehouse, item_id, item_data, having = false
      @warehouse = warehouse
      @item_id, @item_data = item_id, item_data
      @thumb_img = Gosu::Image.new(warehouse.window, @item_data[:thumbnail], false)
      @bg_img = Gosu::Image.new(warehouse.window, having ? 'media/item_already_bought.png' : 'media/item_to_be_bought.png', false)
      @desc_font = Gosu::Font.new(warehouse.window, 'media/hand.ttf', 25)
      @main_font = Gosu::Font.new(warehouse.window, 'media/hand.ttf', 35)
      @x, @y = self.class.get_coordinates
      unless having 
        @buy_button = TextButton.new(warehouse, {:x => @x + BUTTON_X_PAD, :y => @y + BUTTON_Y_PAD, :z => 1, :dx => 144, :dy => 35, :image => :buy}, :buy, @main_font, 0xff000000) { buy }
        @buy_button.activate
      end
      @@count += 1
      @descriptions = @item_data[:description].split(/#/)
    end
    
    def buy
      @warehouse.try_to_buy(@item_id) && (@bg_img = Gosu::Image.new(@warehouse.window, 'media/item_already_bought.png', false)) && @buy_button.deactivate && @buy_button = nil
    end
    
    def draw
      @bg_img.draw(@x, @y, 0)
      @thumb_img.draw(@x + THMB_H_PAD, @y + THMB_V_PAD, 0)
      @main_font.draw("#{@item_data[:name]} ( #{@item_data[:price]}$ )", @x + TITLE_H_PAD, @y + TITLE_V_PAD, 0, 1.0, 1.0, 0xff000000)
      @desc_font.draw(@descriptions.first, @x + DESC_H_PAD, @y + DESC_V_PAD_1, 0, 1.0, 1.0, 0xff000000)
      @desc_font.draw(@descriptions.last, @x + DESC_H_PAD, @y + DESC_V_PAD_2, 0, 1.0, 1.0, 0xff000000)
    end
    
    private
    def self.get_coordinates
      return (@@count/6)*WIDTH, (@@count%6)*HEIGHT + HEIGHT
    end
  end
  
  WIDTH = 1024
  HEIGHT = 768
  
  CASH_LABEL_OFFSET = {:x => WIDTH*1/4, :y => 15}
  ACTION_MESSAGE_OFFSET = {:x => CASH_LABEL_OFFSET[:x], :y => 50}
  BACK_BUTTON_OFFSET = {:x => 590, :y => 40}
  
  def initialize context
    @cursor = Cursor.new
    @warehouse_data = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', 'warehouse-stock.yml'))
    Item.set_counter_for_item_positioning
    @context = context
    @items = []
    @context[:newly_shipped] = {}
  end
  
  def ready_for_update_and_render
    @warehouse_data.each do |item_id, item_data|
      @items << Item.new(self, item_id, item_data, @context[:has_asset_ids].include?(item_id))
    end
    update_cash_left_label
  end
  
  def try_to_buy item_id
    (@context[:money] < @warehouse_data[item_id][:price]) && @action_message.message("You don't have enough money.", ActionMessage::NEGETIVE_MESSAGE_COLOR) && return 
    @context[:money] -= @warehouse_data[item_id][:price]
    @action_message.message("The new #{@warehouse_data[item_id][:name]} has been shipped.")
    @context[:newly_shipped][item_id] = @warehouse_data[item_id]
    update_cash_left_label
  end
  
  def update_cash_left_label
    @cash_left_message.message "You have #{@context[:money]} dollers....", 0xff000000
  end
  
  def window= window
    @window = window
    @print_font = Gosu::Font.new(self.window, 'media/hand.ttf', 35)
    @action_message = ActionMessage.new(@print_font, ACTION_MESSAGE_OFFSET[:x], ACTION_MESSAGE_OFFSET[:y])
    @cash_left_message = ActionMessage.new(@print_font, CASH_LABEL_OFFSET[:x], CASH_LABEL_OFFSET[:y])
    @cursor.window = self
    TextButton.new(self, {:x => BACK_BUTTON_OFFSET[:x], :y => BACK_BUTTON_OFFSET[:y], :z => 1, :dx => 348, :dy => 44, :image => :game_loader}, :get_baking, @print_font).activate
  end
  
  def get_baking
    $wizard.go_to(Shop, :from_file => Util.last_played_file_name(@context), :params => {:warehouse_context => @context})
  end
  
  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
  end
  
  def draw
    @cursor.draw
    @items.each {|item| item.draw }
    for_each_subscriber { |subscriber| subscriber.render}
    @action_message.draw
    @cash_left_message.draw
  end
end