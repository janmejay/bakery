require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'src', 'level')

class OrderBuilderTest < Test::Unit::TestCase
  class ::Oven
  end
  class ::Froster
  end
  class ::Decorator
  end
  class ::ToppingOven
  end
  class ::CookieOven
  end
  
  require File.join(File.dirname(__FILE__), '..', 'src', 'order_builder')
  
  context "An OrderBuilder" do
    context "without cost constraints should discover all physically_possible_combinations" do
      should "the case be simple" do
        assets = [Oven.new, Froster.new]
        combinations = OrderBuilder.physically_possible_combinations(assets).collect {|combination| combination[:builder_sequence]}
        assert(combinations.include?([Oven]))
        assert(combinations.include?([Oven, Froster]))
        assert_equal(2, combinations.length)
      end
      
      should "the case be more complex" do
        assets = [Oven.new, Froster.new, Decorator.new, CookieOven.new]
        combinations = OrderBuilder.physically_possible_combinations(assets).collect {|combination| combination[:builder_sequence]}
        assert(combinations.include?([Oven]))
        assert(combinations.include?([Oven, Froster]))
        assert(combinations.include?([Oven, Decorator]))
        assert(combinations.include?([Oven, Froster, Decorator]))
        assert(combinations.include?([CookieOven]))
        assert_equal(5, combinations.length)
      end
    end
  end
  
  should "filter by users cost preferences" do
    assets = [Oven.new, Froster.new, ToppingOven.new]
    combinations = OrderBuilder.customer_prefered_combinations(Level::Customer.new(:brave_sailor), assets)
    combinations = combinations.collect {|combination| combination[:builder_sequence]}
    assert(combinations.include?([Oven]))
    assert(combinations.include?([Oven, Froster]))
    assert(combinations.include?([Oven, ToppingOven]))
    assert_equal(3, combinations.length)
    combinations = OrderBuilder.customer_prefered_combinations(Level::Customer.new(:rich_businessman), assets)
    combinations = combinations.collect {|combination| combination[:builder_sequence]}
    assert(combinations.include?([Oven, ToppingOven]))
    assert(combinations.include?([Oven, Froster, ToppingOven]))
    assert(combinations.include?([Oven, Froster, ToppingOven, Froster]))
    assert_equal(3, combinations.length)
  end
  
  should "pick one of the top two costliest combinations" do
    
  end
end