module OrderBuilder
  VALID_ORDER_BUILDER_COMBINATIONS = [{:cost_inclination => [:low_cost], :builder_sequence => [Oven]},
                                      {:cost_inclination => [:low_cost], :builder_sequence => [Oven, Froster]},
                                      {:cost_inclination => [:medium_cost], :builder_sequence => [Oven, Froster, Decorator]},
                                      {:cost_inclination => [:low_cost], :builder_sequence => [Oven, Decorator]}, 
                                      {:cost_inclination => [:low_cost, :medium_cost], :builder_sequence => [Oven, ToppingOven]},
                                      {:cost_inclination => [:medium_cost], :builder_sequence => [Oven, Froster, ToppingOven]},
                                      {:cost_inclination => [:medium_cost, :high_cost], :builder_sequence => [Oven, Froster, ToppingOven, Froster]},
                                      {:cost_inclination => [:medium_cost, :high_cost], :builder_sequence => [Oven, Froster, ToppingOven, Decorator]},
                                      {:cost_inclination => [:high_cost], :builder_sequence => [Oven, Froster, ToppingOven, Froster, Decorator]},
                                      {:cost_inclination => [:low_cost, :medium_cost], :builder_sequence => [CookieOven]}]
  
  class Order
    include Actions::ActiveRectangleSubscriber

    SAMPLE_PLATE_OFFSET = {:x => 28, :y => 20}
    
    def initialize plate, customer
      @plate = plate
      @customer = customer
    end
    
    def window= shop_window
      @shop_window = shop_window
      @order_bubble = Gosu::Image.new(@shop_window.window, 'media/order_bubble.png')
      @plate.window = @shop_window
    end
    
    def update_position x, y
      @x, @y= x, y
      @plate.update_position(@x + SAMPLE_PLATE_OFFSET[:x], @y + SAMPLE_PLATE_OFFSET[:y])
    end
    
    def perform_updates; end
    
    def render
      @order_bubble.draw(@x, @y, zindex)
      @plate.render
    end
    
    def activate
      @shop_window.register self
    end

    def handle(event)
      @shop_window.baker.walk_down_and_trigger(event.x, event.y, :satisfy_order, self)
    end
    
    def zindex
      ZOrder::ORDER_BUBBLE
    end
    
    def accept_plate plate
      plate && plate.holder = self
      @shop_window.unregister plate
      @shop_window.unregister self
      @satisfied = true
    end
    
    def satisfied?
      @satisfied
    end
    
    def satisfy_order baker
      @customer.left_the_shop? && return
      baker.has_plate? || return
      baker.is_plate_equal_to?(@plate) || puts("Fuck.. you brought something else... :-)") || return
      baker.give_plate_to(self)
    end
    
    protected
    def active_x
      return @x, @x + 109
    end

    def active_y
      return @y, @y + 100
    end
  end
  
  VALID_ORDER_BUILDER_COMBINATIONS.each do |valid_combination|
    valid_combination[:cost] = valid_combination[:builder_sequence].inject(0) {|sum, seq| seq::COST + sum }
  end
  
  def self.can_support?(cost_inclination, with_assets)
    not physically_possible_combinations(with_assets).select { |combination| combination[:cost_inclination].include?(cost_inclination) }.empty?
  end
                  
  def self.physically_possible_combinations assets
    available_order_builders = assets.collect {|asset| asset.class }
    VALID_ORDER_BUILDER_COMBINATIONS.select {|combi| combi[:builder_sequence].inject(true) { |result, builder| result && available_order_builders.include?(builder)}}
  end
  
  def self.customer_prefered_combinations customer, assets
    valid_combinations = physically_possible_combinations assets
    valid_combinations.select {|combi| combi[:cost_inclination].include?(customer.cost_inclination)}
  end
  
  def self.order_combination_for customer, assets
    top_two = customer_prefered_combinations(customer, assets).sort {|one, another| another[:cost] <=> one[:cost]}[0...2]
    top_two[rand(top_two.length)]
  end
  
  def self.build_for customer, assets
    order_combination = order_combination_for(customer, assets)
    builder_assets = order_combination[:builder_sequence].map { |builder_klass| assets.select { |asset| asset.class == builder_klass }}
    builder_sequence = builder_assets.map { |to_be_builders| to_be_builders[rand(to_be_builders.length)] }
    sample_plate = builder_sequence.inject(nil) { |product_sample, builder| builder.build_sample_on(product_sample) }
    return Order.new(sample_plate, customer), order_combination[:cost]
  end
  
end