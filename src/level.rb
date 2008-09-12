class Level 
  LEVELS_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'levels.yml'))
  
  class Customer
    
    CUSTOMER_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'customers.yml'))
    
    def self.cost_inclination_for type
      CUSTOMER_CONFIG[type][:cost_inclination]
    end
    
    def initialize name
      @name = name
      @cost_inclination = CUSTOMER_CONFIG[@name][:cost_inclination]
      @time = Time.now
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
    end
    
    def update(xy_map)
      @x, @y = xy_map[:x], xy_map[:y]
      @order_sample.update_position(@x + 80, @y + 30)
    end
    
    def draw
      @body.draw(@x, @y, ZOrder::CUSTOMER)
      @order_sample.render
    end
    
    def done?
      @time && (@time + 10 < Time.now)
    end
  end
  
  class CustomerQueue
    
    CUSTOMER_POSITIONS = [{:x => 100, :y => 150},
                          {:x => 90, :y => 300}, 
                          {:x => 100, :y => 450},
                          {:x => 140, :y => 600}].reverse
    
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
    customer = create_customer
    order, price = OrderBuilder.build_for(customer, @shop_window.assets)
    order.window = @shop_window
    customer.order = order
    customer.minimum_payment = price
    customer
  end
  
  def create_customer
    random_number = rand(100)
    customer = nil
    @customer_types.keys.sort.each do |probablity_percentage|
      (random_number > probablity_percentage) && next
      (customer = Customer.new(@customer_types[probablity_percentage])) && break
    end
    customer.window = @shop_window
    customer
  end
end