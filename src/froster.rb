require 'util/animator'
require 'util/actions'
require 'util/process_runner'
require File.join(File.dirname(__FILE__), "common", "button")

class Froster
  attr_reader :window
  PROCESS_RUNNER_OFFSET = {:x => 75, :y => 15}
  
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
  end
  
  def blackcurrent_frosting
    puts "Asking for blackcurrent_frosting"
  end
  
  def vanilla_frosting
    puts "Asking for vanilla_frosting"
  end
  
  def mint_frosting
    puts "Asking for mint_frosting"
  end
  
  def jelly_frosting
    puts "Asking for jelly_frosting"
  end

  def draw
    @body.draw(563, 635, ZOrder::TABLE_MOUNTED_EQUIPMENTS)
    @buttons.each { |button| button.render }
  end
end
