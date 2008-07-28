require 'util/animator'
require 'util/actions'
require 'util/process_runner'
require File.join(File.dirname(__FILE__), "common", "button")

class Froster
  attr_reader :window
  PROCESS_RUNNER_OFFSET = {:x => 75, :y => 15}
  CAKE_PLATE_OFFSET = {:x => 30, :y => 21}
  X, Y = 563, 635
  
  def initialize window
    @window = window
    @body = Gosu::Image.new(@window, 'media/froster.png', true)
    @buttons = []
    @buttons << Button.new(self, {:x => 568, :y => 653, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 24, :dy => 24}, :blackcurrent_frosting)
    @buttons << Button.new(self, {:x => 568, :y => 695, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 24, :dy => 24}, :vanilla_frosting)
    @buttons << Button.new(self, {:x => 654, :y => 653, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 24, :dy => 24}, :mint_frosting)
    @buttons << Button.new(self, {:x => 654, :y => 695, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 24, :dy => 24}, :jelly_frosting)
    @buttons.each do |button|
      button.activate
    end
  end

  def update
    @plate && @plate.update_position(X + CAKE_PLATE_OFFSET[:x], Y + CAKE_PLATE_OFFSET[:y])
  end
  
  def receive_cake
    @plate = @window.baker.return_plate
    @plate.holder = self
  end
  
  def blackcurrent_frosting
    receive_cake && @plate.cake.put_icing(:blackcurrent)
  end
  
  def vanilla_frosting
    receive_cake && @plate.cake.put_icing(:vanilla)
  end
  
  def mint_frosting
    receive_cake && @plate.cake.put_icing(:mint)
  end
  
  def jelly_frosting
    receive_cake && @plate.cake.put_icing(:jelly)
  end
  
  def give_plate_to baker
    baker.pick_up_plate(@plate)
    @plate = nil
  end

  def draw
    @body.draw(X, Y, ZOrder::TABLE_MOUNTED_EQUIPMENTS)
    @buttons.each { |button| button.render }
  end
end
