require File.join('util', 'position_animation')

class Level 
  LEVELS_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'levels.yml'))
  
  class Customer
    
    CUSTOMER_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'customers.yml'))
    HEARTS_OFFSET = {:x => -25, :dx => -6, :y => 34}
    
    ENTERANCE = {:x => 100, :y => 0}
    EXIT = {:x => -200}
    
    def self.cost_inclination_for type
      CUSTOMER_CONFIG[type][:cost_inclination]
    end
    
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
    
    def minimum_payment= payment
      @payment = payment
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
      @body.draw(@x, @y, ZOrder::CUSTOMER)
      @leaving_the_shop || @order_sample.render
      @number_of_patience_units_left.times { |i| @patience_unit.draw(@x + HEARTS_OFFSET[:x] + HEARTS_OFFSET[:dx]*i, @y + HEARTS_OFFSET[:y], ZOrder::CUSTOMER) }
    end
    
    def leave_the_shop_if_done
      (@patience_timeout == 0) && leave_the_shop
    end
    
    def left_the_shop?
      @left
    end
    
    def enter_the_shop go_to
      @entered_the_shop_at = Time.now
      @movement_anim = Util::PositionAnimation.new(ENTERANCE, go_to, 15)
      @movement_anim.start
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
      @leaving_the_shop = true
    end
    
    def free_place_in_the_queue *ignore
      @left = true
    end
  end
  
  class CustomerQueue
    
    CUSTOMER_POSITIONS = [{:x => 93, :y => 230},
                          {:x => 90, :y => 340}, 
                          {:x => 100, :y => 450},
                          {:x => 124, :y => 560}].reverse
    
    def initialize
      @queue = []
      @in_shop_queue = []
    end
    
    def window= shop_window
      @queue.each {|customer| customer.window = shop_window }
      @in_shop_queue.each {|customer| customer.window = shop_window}
    end
    
    def update
      (4 - @in_shop_queue.length).times { add_a_new_customer }
      
      unsatisfied_customer_count = 0
      @in_shop_queue.dup.each do |customer|
        customer.left_the_shop? && @in_shop_queue.delete(customer) && next
        customer.update(CUSTOMER_POSITIONS[unsatisfied_customer_count])
        unsatisfied_customer_count += 1
      end
    end
    
    def draw
      @in_shop_queue.each {|customer| customer.draw }
    end
    
    def << new_customer
      @queue << new_customer
    end
    
    private
    
    def add_a_new_customer
      @queue.empty? && return
      @in_shop_queue << customer = @queue.shift
      customer && customer.enter_the_shop(CUSTOMER_POSITIONS[@in_shop_queue.length - 1])
    end
  end
  
  def initialize player_context
    @level = LEVELS_CONFIG[player_context[:level]]
    @level_timeout = @level[:timeout]
    @required_earning = @level[:required_earning]
    @possible_earning = @required_earning*@level[:factor_of_safty]
    @customer_queue = CustomerQueue.new 
  end
  
  def window= shop_window
    @shop_window = shop_window
    @customer_types = {}
    @level[:customer_types].each do |percentage, customer_type| 
      OrderBuilder.can_support?(Customer.cost_inclination_for(customer_type), @shop_window.assets) && @customer_types[percentage] = customer_type
    end
    @earning_oppourtunity_ensured = 0
    while @earning_oppourtunity_ensured < @possible_earning 
      @earning_oppourtunity_ensured += add_customer
    end
    @customer_queue.window = @shop_window
  end
  
  def update
    @customer_queue.update
  end
  
  def draw
    @customer_queue.draw
  end
  
  def add_customer
    random_number = rand(100)
    customer = nil
    @customer_types.keys.sort.each do |probablity_percentage|
      (random_number > probablity_percentage) && next
      (customer = Customer.new(@customer_types[probablity_percentage])) && break
    end
    customer.order, price = OrderBuilder.build_for(customer, @shop_window.assets)
    customer.minimum_payment = price
    @customer_queue << customer
    price
  end
end