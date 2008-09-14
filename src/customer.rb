class Customer
  
  class Money
    include Actions::ActiveRectangleSubscriber
    
    MONEY_OFFSET = {:x => 140, :y => 40}
    
    def initialize customer
      @customer = customer
      @amount = @customer.payment + @customer.tip_amount
      @x, @y = MONEY_OFFSET[:x] + @customer.x, MONEY_OFFSET[:y] + @customer.y
      self.window = customer.shop_window
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
  HEARTS_OFFSET = {:x => -25, :dx => -6, :y => 34}
  
  ENTERANCE = {:x => 100, :y => 0}
  EXIT = {:x => -200}
  
  def self.cost_inclination_for type
    CUSTOMER_CONFIG[type][:cost_inclination]
  end
  
  attr_accessor :payment
  attr_reader :x, :y, :shop_window
  
  def initialize name
    @name = name
    @cost_inclination = CUSTOMER_CONFIG[@name][:cost_inclination]
    @patience_factor = CUSTOMER_CONFIG[@name][:patience_factor]
    @patience_timeout = @patience_factor*CUSTOMER_CONFIG[@name][:patience_count]
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
  end
  
  def update(xy_map)
    x, y = xy_map[:x], xy_map[:y]
    #5 stands for significant displacement
    if !@movement_anim.running? && ((@x != x) || (@y != y))
      @movement_anim = Util::PositionAnimation.new({:x => @x, :y => @y}, {:x => x, :y => y}, 5)
      @movement_anim.start
    end
    
    @x, @y = @movement_anim.hop
    @order_sample.update_position(@x + 80, @y + 30)
    @number_of_patience_units_left = (@patience_timeout/@patience_factor).to_i
    @leaving_the_shop || leave_the_shop_if_done
    update_patience_timeout
  end
  
  def draw
    @dont_draw_customer && return
    @body.draw(@x, @y, ZOrder::CUSTOMER)
    @leaving_the_shop || @order_sample.render
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
    @movement_anim = Util::PositionAnimation.new(ENTERANCE, go_to, 15)
    @movement_anim.start
    @order_sample.activate
  end

  def tip_amount
    rand(@number_of_patience_units_left)
  end

  def free_customers_place
    @free_customers_place = true
  end
  
  private
  
  def update_patience_timeout
    time_now = Time.now.to_i
    (@last_updated_on == time_now) && return
    @patience_timeout -= 1
    @last_updated_on = time_now
  end
  
  def leave_the_shop
    @movement_anim = Util::PositionAnimation.new({:x => @x, :y => @y}, EXIT.merge(:y => @y), 20, false, {90 => :free_place_in_the_queue}, self)
    @movement_anim.start
    @shop_window.unregister @order_sample
    @leaving_the_shop = true
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