class Level 
  LEVELS_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'levels.yml'))
  
  class Customer
    
    CUSTOMER_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'customers.yml'))
    HEARTS_OFFSET = {:x => -25, :dx => -6, :y => 34}
    
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
    
    def entered_the_shop
      @entered_the_shop_at = Time.now
    end
        
    def window= shop_window
      @shop_window = shop_window
      @body = Gosu::Image.new(@shop_window.window, "media/#{@name}.png")
      @order_sample.window = @shop_window
      @patience_unit = Gosu::Image.new(shop_window.window, "media/patience.png")
    end
    
    def update(xy_map)
      @x, @y = xy_map[:x], xy_map[:y]
      @order_sample.update_position(@x + 80, @y + 30)
      @number_of_patience_units_left = ((@patience_timeout - (Time.now - @entered_the_shop_at))/@patience_factor).to_i
    end
    
    def draw
      @body.draw(@x, @y, ZOrder::CUSTOMER)
      @order_sample.render
      @number_of_patience_units_left.times { |i| @patience_unit.draw(@x + HEARTS_OFFSET[:x] + HEARTS_OFFSET[:dx]*i, @y + HEARTS_OFFSET[:y], ZOrder::CUSTOMER) }
    end
    
    def done?
      @patience_timeout < (Time.now - @entered_the_shop_at)
    end
  end
  
  class CustomerQueue
    
    CUSTOMER_POSITIONS = [{:x => 100, :y => 230},
                          {:x => 90, :y => 340}, 
                          {:x => 100, :y => 450},
                          {:x => 130, :y => 560}].reverse
    
    def initialize
      @queue = []
    end
    
    def window= shop_window
      @queue.each {|customer| customer.window = shop_window }
    end
    
    def update
      unsatisfied_customer_count = 0
      done_customers = []
      @queue.each do |customer|
        customer.done? && (done_customers << customer) && next
        customer.update(CUSTOMER_POSITIONS[unsatisfied_customer_count])
        unsatisfied_customer_count += 1
      end
      @queue -= done_customers
    end
    
    def draw
      @queue.each {|customer| customer.draw }
    end
    
    def number_of_customers
      @queue.length
    end
    
    def new_customer customer
      @queue << customer
      customer.entered_the_shop
    end
  end
  
  def initialize player_context
    @level = LEVELS_CONFIG[player_context[:level]]
    @customer_queue = CustomerQueue.new
    @total_number_of_customers_expected = @level[:factor_of_safty]*@level[:expected_earnings]
  end
  
  def window= shop_window
    @shop_window = shop_window
    @customer_queue.window = @shop_window
    @customer_types = {}
    @level[:customer_types].each do |percentage, customer_type| 
      OrderBuilder.can_support?(Customer.cost_inclination_for(customer_type), @shop_window.assets) && @customer_types[percentage] = customer_type
    end
  end
  
  def update
    (@customer_queue.number_of_customers < 4) && @customer_queue.new_customer(dispense_customer)
    @customer_queue.update
  end
  
  def draw
    @customer_queue.draw
  end
  
  def dispense_customer
    random_number = rand(100)
    customer = nil
    @customer_types.keys.sort.each do |probablity_percentage|
      (random_number > probablity_percentage) && next
      (customer = Customer.new(@customer_types[probablity_percentage])) && break
    end
    order, price = OrderBuilder.build_for(customer, @shop_window.assets)
    customer.order = order
    customer.minimum_payment = price
    customer.window = @shop_window
    customer
  end
end