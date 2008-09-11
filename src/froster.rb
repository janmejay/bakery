require 'util/animator'
require 'util/actions'
require 'util/process_runner'

class Froster
  
  include AliveAsset
  
  PROCESS_RUNNER_OFFSET = {:x => 34, :y => 27}
  CAKE_PLATE_OFFSET = {:x => 30, :y => 21}
  BUTTON_OFFSET = [
      {:x => 5, :y => 18}, {:x => 91, :y => 18},
      {:x => 5, :y => 60}, {:x => 91, :y => 60}
    ]
    
  COST = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'returns.yml'))[:icing]
  
  def initialize context_froster_data
    @context_froster_data = context_froster_data
    @x, @y = @context_froster_data[:x], @context_froster_data[:y]
    @buttons = []
    @action_anim = Util::Animator.new('media/cake-action-anim.png', 120, 100, :chunk_slice_width => 3, :run_indefinitly => true)
    @icing_process = Util::ProcessRunner.new(10, @x + PROCESS_RUNNER_OFFSET[:x], @y + PROCESS_RUNNER_OFFSET[:y], :make_cake_available_after_icing, self)
  end
  
  def window= shop_window
    @shop_window = shop_window
    @body = Gosu::Image.new(@shop_window.window, @context_froster_data[:machine_view], true)
    @this_cake_is_already_iced_message = Gosu::Sample.new(@shop_window.window, 'media/this_cake_is_already_iced.ogg')
    @cookies_can_not_be_iced_message = Gosu::Sample.new(@shop_window.window, 'media/cookies_can_not_be_iced.ogg')
    @action_anim.window = @shop_window.window
    @icing_process.window = @shop_window.window
    @context_froster_data[:buttons].each_with_index do |button, index|
      GameButton.new(self, {:x => @x + BUTTON_OFFSET[index][:x], :y => @y + BUTTON_OFFSET[index][:y], :z => ZOrder::TABLE_MOUNTED_CONTROLS, 
        :dx => 24, :dy => 24}, button).activate
    end
    @plate && @plate.window = @shop_window
  end
  
  def window
    @shop_window
  end

  def update
    @plate && @plate.update_position(@x + CAKE_PLATE_OFFSET[:x], @y + CAKE_PLATE_OFFSET[:y])
    @icing_process.update
  end
  
  def receive_cake
    verify_cake_is_not_iced_already || return
    @shop_window.baker.give_plate_to(self)
    return unless @plate && @plate.holder = self
    @action_anim.start
    @icing_process.start
    @show_animation = true #REFACTOR ME!!!! put me in the animator
  end
  
  def blackcurrent_frosting *ignore
    receive_cake && @plate.cake.put_icing(:blackcurrent)
  end
  
  def vanilla_frosting *ignore
    receive_cake && @plate.cake.put_icing(:vanilla)
  end
  
  def mint_frosting *ignore
    receive_cake && @plate.cake.put_icing(:mint)
  end
  
  def jelly_frosting *ignore
    receive_cake && @plate.cake.put_icing(:jelly)
  end
    
  def mizuame_frosting *ignore
    receive_cake && @plate.cake.put_icing(:mizuame)
  end
  
  def butterscotch_frosting *ignore
    receive_cake && @plate.cake.put_icing(:butterscotch)
  end
  
  def dark_chocolate_frosting *ignore
    receive_cake && @plate.cake.put_icing(:dark_chocolate)
  end
  
  def caramel_frosting *ignore
    receive_cake && @plate.cake.put_icing(:caramel)
  end
  
  def give_plate_to baker
    baker.accept_plate(@plate) && @plate = nil
  end
  
  def accept_plate plate
    @shop_window.unregister(plate)
    @plate = plate
  end

  def draw
    @body.draw(@x, @y, ZOrder::TABLE_MOUNTED_EQUIPMENTS)
    @show_animation && @action_anim.slide.draw(@x, @y, ZOrder::ACTION_CLOWD)
    @icing_process.render
    @plate && @plate.render
  end
  
  private
  def make_cake_available_after_icing
    @shop_window.register(@plate)
    @action_anim.stop
    @show_animation = false
  end
  
  def verify_cake_is_not_iced_already
    plate = @plate || @shop_window.baker.plate
    plate && plate.has_cookies? && @cookies_can_not_be_iced_message.play && return
    plate && plate.cake.iced? && @this_cake_is_already_iced_message.play && return
    true
  end
end
