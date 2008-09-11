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
  
  VALID_ORDER_BUILDER_COMBINATIONS.each do |valid_combination|
    valid_combination[:cost] = valid_combination[:builder_sequence].inject(0) {|sum, seq| seq::COST + sum }
  end
  
                  
  def self.physically_possible_combinations assets
    available_order_builders = assets.collect {|asset| asset.class }
    VALID_ORDER_BUILDER_COMBINATIONS.select {|combi| combi[:builder_sequence].inject(true) { |result, builder| result && available_order_builders.include?(builder)}}
  end
  
  def self.customer_prefered_combinations customer, assets
    valid_combinations = physically_possible_combinations assets
    valid_combinations.select {|combi| combi[:cost_inclination].include?(customer.cost_inclination)}
  end
  
  def self.order_for customer, assets
    customer_prefered_combinations(customer, assets).sort {|one, another| another[:cost] <=> one[:cost]}[0...2][rand(1)]
  end
  
end