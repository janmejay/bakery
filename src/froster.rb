require 'util/animator'
require 'util/actions'
require 'util/process_runner'

class Froster
  attr_reader :window
  PROCESS_RUNNER_OFFSET = {:x => 34, :y => 27}
  CAKE_PLATE_OFFSET = {:x => 30, :y => 21}
  X, Y = 563, 635
  
  def initialize window
    @window = window
    @body = Gosu::Image.new(@window, 'media/froster.png', true)
    @buttons = []
    @this_cake_is_already_iced_message = Gosu::Sample.new(@window, 'media/this_cake_is_already_iced.ogg')
    @action_anim = Util::Animator.new(window, 'media/cake-action-anim.png', 120, 100, false, 3, true)
    @icing_process = Util::ProcessRunner.new(@window, 10, X + PROCESS_RUNNER_OFFSET[:x], Y + PROCESS_RUNNER_OFFSET[:y]) { make_cake_available_after_icing }
    @buttons << GameButton.new(self, {:x => 568, :y => 653, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 24, :dy => 24}, :blackcurrent_frosting)
    @buttons << GameButton.new(self, {:x => 568, :y => 695, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 24, :dy => 24}, :vanilla_frosting)
    @buttons << GameButton.new(self, {:x => 654, :y => 653, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 24, :dy => 24}, :mint_frosting)
    @buttons << GameButton.new(self, {:x => 654, :y => 695, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 24, :dy => 24}, :jelly_frosting)
    @buttons.each do |button|
      button.activate
    end
  end

  def update
    @plate && @plate.update_position(X + CAKE_PLATE_OFFSET[:x], Y + CAKE_PLATE_OFFSET[:y])
    @icing_process.update
  end
  
  def receive_cake
    verify_cake_is_not_iced_already || return
    @window.baker.give_plate_to(self)
    return unless @plate && @plate.holder = self
    @action_anim.start
    @icing_process.start
    @show_animation = true #REFACTOR ME!!!! put me in the animator
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
    baker.accept_plate(@plate) && @plate = nil
  end
  
  def accept_plate plate
    @window.unregister(plate)
    @plate = plate
  end

  def draw
    @body.draw(X, Y, ZOrder::TABLE_MOUNTED_EQUIPMENTS)
    @show_animation && @action_anim.slide.draw(X, Y, ZOrder::ACTION_CLOWD)
    @icing_process.render
    @plate && @plate.render
  end
  
  private
  def make_cake_available_after_icing
    @window.register(@plate)
    @action_anim.stop
    @show_animation = false
  end
  
  def verify_cake_is_not_iced_already
    plate = @plate || @window.baker.plate
    plate && plate.cake.iced? && @this_cake_is_already_iced_message.play && return
    true
  end
end
