require File.join('util', 'position_animation')
require 'customer'

class Level 
  LEVELS_CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'levels.yml'))
  
  class CustomerQueue
    
    CUSTOMER_POSITIONS = [{:x => 140, :y => 270},
                          {:x => 137, :y => 380}, 
                          {:x => 147, :y => 490},
                          {:x => 171, :y => 600}].reverse
                          
    MAX_CUSTOMERS_IN_SHOP = CUSTOMER_POSITIONS.length
    
    PROBABLITY_BASE = 100000
    
    def initialize level_data
      @queue = []
      @in_shop_queue = []
      @grouping_probablity = level_data[:grouping_probablity]
      @min_free_slot_limit = level_data[:min_free_slot_limit]
      @min_slot_respecting_probablity = level_data[:min_slot_respecting_probablity]
    end
    
    def window= shop_window
      @queue.each {|customer| customer.window = shop_window }
      @in_shop_queue.each {|customer| customer.window = shop_window}
    end
    
    def update
      (@in_shop_queue.length < MAX_CUSTOMERS_IN_SHOP) && consider_pushing_customers_in
      
      unsatisfied_customer_count = 0
      @in_shop_queue.dup.each do |customer|
        customer.left_the_shop? && @in_shop_queue.delete(customer) && next
        customer.update(CUSTOMER_POSITIONS[unsatisfied_customer_count])
        unsatisfied_customer_count += 1
      end
    end
    
    def draw
      @in_shop_queue.each {|customer| customer.render }
    end
    
    def << new_customer
      @queue << new_customer
    end
    
    private
    
    def add_new_customers number = 1
      number.times do
        @queue.empty? && return
        @in_shop_queue << customer = @queue.shift
        customer && customer.enter_the_shop(CUSTOMER_POSITIONS[@in_shop_queue.length - 1])
      end
    end
    alias_method :add_new_customer, :add_new_customers
    
    def consider_pushing_customers_in
      slots_available = MAX_CUSTOMERS_IN_SHOP - @in_shop_queue.length
      (slots_available >= @min_free_slot_limit) && (rand(PROBABLITY_BASE) < @grouping_probablity) && add_new_customers(rand(@min_free_slot_limit) + 1) && return
      (rand(PROBABLITY_BASE) > @min_slot_respecting_probablity) && (slots_available > 0) && add_new_customer && return
      (@in_shop_queue.length == 0) && add_new_customer
    end
  end
  
  def initialize player_context
    @level = LEVELS_CONFIG[player_context[:level]]
    @level_timeout = @level[:timeout]
    @required_earning = @level[:required_earning]
    @possible_earning = @required_earning*(1 + @level[:factor_of_safty])
    @customer_queue = CustomerQueue.new @level.dup
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
    customer.payment = price
    @customer_queue << customer
    price
  end
end