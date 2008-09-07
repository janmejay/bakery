
class ToppingOven < Oven
  
  class ToppingButton < Button
    
    def trigger_to_start_baking baker
      @oven.verify_cake_is_nither_decorated_nor_topped(baker) || return
      baker.give_plate_to(@oven)
      @oven.bake(@cake_name) unless @oven.baking?
    end
    
  end
  
  BUTTON_KLASS = ToppingButton
  
  BUTTON_OFFSETS = [{:x_off => 22, :y_off => 49}, {:x_off => 52, :y_off => 49}, {:x_off => 82, :y_off => 49}, {:x_off => 113, :y_off => 49}]
  
  def window= shop_window
    super
    @this_cake_is_already_topped = Gosu::Sample.new(@shop_window.window, 'media/this_cake_is_already_topped.ogg')
    @a_decorated_cake_can_not_be_topped = Gosu::Sample.new(@shop_window.window, 'media/a_decorated_cake_can_not_be_topped.ogg')
  end
  
  def put_baked_cake *ignore
    @plate.cake.put_topping @cake
    @plate.holder = self
  end

  def accept_plate plate
    @shop_window.unregister(plate)
    @plate = plate
  end
  
  def verify_cake_is_nither_decorated_nor_topped baker
    given_plate = @plate || baker.plate
    given_plate || return
    given_plate.cake.decorated? && @a_decorated_cake_can_not_be_topped.play && return
    given_plate.cake.topped? && @this_cake_is_already_topped.play && return
    true
  end
end
