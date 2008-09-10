class Level 
  LEVELS_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'levels.yml'))
  
  class Customer
    def initialize name
      @name = name
      @time = Time.now
    end
    
    def window= shop_window
      @shop_window = shop_window
      @body = Gosu::Image.new(@shop_window.window, "media/#{@name}.png")
    end
    
    def update(xy_map)
      @x, @y = xy_map[:x], xy_map[:y]
    end
    
    def draw
      @body.draw(@x, @y, ZOrder::CUSTOMER)
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
    @customer_types = @level[:customer_types]
    @customer_queue = CustomerQueue.new
    @total_number_of_customers_expected = @level[:factor_of_safty]*@level[:expected_earnings]
  end
  
  def window= shop_window
    @shop_window = shop_window
    @customer_queue.window = @shop_window
  end
  
  def update
    (@customer_queue.number_of_customers < 4) && @customer_queue.new_customer(dispense_customer)
    @customer_queue.update
  end
  
  def draw
    @customer_queue.draw
  end
  
  def dispense_customer
    create_customer
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