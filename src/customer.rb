class Customer
  
  class Money
    include Actions::ActiveRectangleSubscriber
    
    MONEY_OFFSET = {:x => 95, :y => 0}
    
    def initialize customer
      @customer = customer
      @amount = @customer.payment + @customer.tip_amount
      @x = MONEY_OFFSET[:x] + @customer.x
      perform_updates
      self.window = customer.shop_window
    end
    
    def perform_updates
      @y = MONEY_OFFSET[:y] + @customer.y
    end
    
    def window= shop_window
      @shop_window = shop_window
      @body = Gosu::Image.new(@shop_window.window, 'media/money.png', true)
    end
    
    def render
      @body.draw(@x, @y, zindex)
    end
    
    def zindex
      ZOrder::TABLE_MOUNTED_EQUIPMENTS
    end
    
    def handle(event)
      @shop_window.baker.walk_down_and_trigger(event.x, event.y, :jump_to_bakers_wallet, self)
    end

    protected
    def active_x
      return @x, @x + @body.width
    end

    def active_y
      return @y, @y + @body.height
    end
    
    private
    def jump_to_bakers_wallet *ignore
      @shop_window.unregister self
      @customer.free_customers_place
    end
  end
  
  CUSTOMER_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'customers.yml'))
  HEARTS_OFFSET = {:x => -75, :dx => -6, :y => 0}
  
  ENTERANCE = {:x => 100, :y => 0}
  EXIT = {:x => -200}
  
  ORDER_BOX_OFFSET = {:x => 38, :y => -15}
  
  MENU_CARD_OFFSET = {:x => 60, :y => -20}
  
  X_INCREMENT_WHEN_READING_MENU = 30
  
  def self.cost_inclination_for type
    CUSTOMER_CONFIG[type][:cost_inclination]
  end
  
  attr_accessor :payment
  attr_reader :x, :y, :shop_window
  
  include Actions::ActiveRectangleSubscriber
  
  def initialize name
    @name = name
    @cost_inclination = CUSTOMER_CONFIG[@name][:cost_inclination]
    @patience_factor = CUSTOMER_CONFIG[@name][:patience_factor]
    @patience_timeout = @patience_factor*CUSTOMER_CONFIG[@name][:patience_count]
    @hasnt_ordered_yet = true
    @body_angle = 0
  end
  
  def cost_inclination
    @cost_inclination
  end
  
  def order= order_sample
    @order_sample = order_sample
  end
      
  def window= shop_window
    @shop_window = shop_window
    @body = Gosu::Image.new(@shop_window.window, "media/#{@name}.png")
    @order_sample.window = @shop_window
    @patience_unit = Gosu::Image.new(shop_window.window, "media/patience.png")
    @menu_card = Gosu::Image.new(shop_window.window, "media/menu_card.png")
  end
  
  def update(xy_map)
    x, y = xy_map[:x], xy_map[:y]
    #5 stands for significant displacement
    if !@movement_anim.running? && ((@x != x) || (@y != y))
      @movement_anim = Util::PositionAnimation.new({:x => @x, :y => @y}, {:x => x, :y => y}, 5)
      @movement_anim.start
    end
    
    @hasnt_ordered_yet && order_if_decided
    
    @x, @y = @movement_anim.hop
    @order_sample.update_position(@x + ORDER_BOX_OFFSET[:x], @y + ORDER_BOX_OFFSET[:y])
    @number_of_patience_units_left = (@patience_timeout/@patience_factor).to_i
    @leaving_the_shop || leave_the_shop_if_done
    update_timeouts
  end
  
  def render
    @dont_draw_customer && return
    @body.draw_rot(@x + (@has_menu_card ? X_INCREMENT_WHEN_READING_MENU : 0), @y, zindex, @body_angle)
    @leaving_the_shop || @hasnt_ordered_yet || @order_sample.render
    @has_menu_card && @menu_card.draw(@x + MENU_CARD_OFFSET[:x], @y + MENU_CARD_OFFSET[:y], ZOrder::TABLE_MOUNTED_EQUIPMENTS)
    @number_of_patience_units_left.times { |i| @patience_unit.draw(@x + HEARTS_OFFSET[:x] + HEARTS_OFFSET[:dx]*i, @y + HEARTS_OFFSET[:y], ZOrder::CUSTOMER) }
  end
  
  def leave_the_shop_if_done
    ((@patience_timeout == 0) || @order_sample.satisfied?) && leave_the_shop
  end
  
  def left_the_shop?
    @order_sample.satisfied? ? @left && @free_customers_place : @left
  end
  
  def enter_the_shop go_to
    @entered_the_shop_at = Time.now
    @movement_anim = Util::PositionAnimation.new(ENTERANCE, go_to, 15, false, {90 => :get_ready_to_accept_menu_card}, self)
    @movement_anim.start
  end
  
  def handle(event)
    @shop_window.baker.walk_down_and_trigger(event.x, event.y, :take_the_menu_card, self)
  end
  
  def take_the_menu_card *ignore
    @has_menu_card = true
    @going_to_order_after = rand(CUSTOMER_CONFIG[@name][:max_time_to_decide_order])
    @body_angle = 270
  end
  
  def order_if_decided
    (@going_to_order_after == 0) || return
    @hasnt_ordered_yet = false
    @order_sample.activate
    @has_menu_card = false
    @shop_window.unregister self
    @body_angle = 0
  end
  
  def get_ready_to_accept_menu_card *ignore
    @shop_window.register self
  end
  
  def zindex
    ZOrder::CUSTOMER
  end

  def tip_amount
    rand(@number_of_patience_units_left)
  end

  def free_customers_place
    @free_customers_place = true
  end
  
  protected
  def active_x
    dx = @body.width/2
    return @x - dx, @x + dx
  end

  def active_y
    dy = @body.height/2
    return @y - dy, @y + dy
  end
  
  private
  def update_timeouts
    time_now = Time.now.to_i
    (@last_updated_on == time_now) && return
    @patience_timeout -= 1
    @going_to_order_after && (@going_to_order_after -= 1)
    @last_updated_on = time_now
  end
  
  def leave_the_shop
    @movement_anim = Util::PositionAnimation.new({:x => @x, :y => @y}, EXIT.merge(:y => @y), 20, false, {90 => :free_place_in_the_queue}, self)
    @movement_anim.start
    @shop_window.unregister @order_sample
    @leaving_the_shop = true
    @body_angle = 0
    @has_menu_card = false
    @order_sample.satisfied? && put_money_on_the_table
  end
  
  def free_place_in_the_queue *ignore
    @left = true
    @dont_draw_customer = true
  end
  
  def put_money_on_the_table
    @shop_window.register(Money.new(self))
  end
end