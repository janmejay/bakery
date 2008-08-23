class Decorator
  PROCESS_RUNNER_OFFSET = {:x => 25, :y => 45}
  CAKE_PLATE_OFFSET = {:x => 20, :y => 39}
  ACTION_OFFSET = {:x => -10, :y => 20}
  BUTTON_OFFSETS = [
      {:x => 22, :y => 12}, {:x => 50, :y => 12},
      {:x => 22, :y => 100}, {:x => 50, :y => 100}
    ]

  def initialize shop_window, context_decorator_data
    @shop_window = shop_window
    @x, @y = 900, 300
    @body = Gosu::Image.new(@shop_window.window, context_decorator_data[:machine_view], true)
    @buttons = []
    @action_anim = Util::Animator.new(@shop_window.window, 'media/cake-action-anim.png', 120, 100, false, 3, true)
    @this_cake_is_already_decorated_message = Gosu::Sample.new(@shop_window.window, 'media/this_cake_is_already_decorated.ogg')
    @decoration_process = Util::ProcessRunner.new(@shop_window.window, 10, @x + PROCESS_RUNNER_OFFSET[:x],
                                                               @y + PROCESS_RUNNER_OFFSET[:y]) { make_cake_available_after_decoration }
    context_decorator_data[:buttons].each_with_index do |button, index|
      GameButton.new(self, {:x => @x + BUTTON_OFFSETS[index][:x], :y => @y + BUTTON_OFFSETS[index][:y], 
        :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 28, :dy => 28}, button).activate
    end
  end
  
  def window
    @shop_window
  end

  def update
    @plate && @plate.update_position(@x + CAKE_PLATE_OFFSET[:x], @y + CAKE_PLATE_OFFSET[:y])
    @decoration_process.update
  end

  def receive_cake
    verify_cake_is_not_decorated_already || return
    @shop_window.baker.give_plate_to(self)
    return unless @plate && @plate.holder = self
    @action_anim.start
    @decoration_process.start
    @show_animation = true #REFACTOR ME!!!! put me in the animator
  end

  def candle_decoration
    receive_cake && @plate.cake.put_decoration(:candle)
  end                               
                                    
  def tree_decoration               
    receive_cake && @plate.cake.put_decoration(:tree)
  end                               
                                    
  def boat_decoration               
    receive_cake && @plate.cake.put_decoration(:boat)
  end                               
                                    
  def face_decoration               
    receive_cake && @plate.cake.put_decoration(:face)
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
    @show_animation && @action_anim.slide.draw(@x + ACTION_OFFSET[:x], @y + ACTION_OFFSET[:y], ZOrder::ACTION_CLOWD)
    @decoration_process.render
    @plate && @plate.render
  end

  private
  def make_cake_available_after_decoration
    @shop_window.register(@plate)
    @action_anim.stop
    @show_animation = false
  end

  def verify_cake_is_not_decorated_already
    plate = @plate || @shop_window.baker.plate
    plate && plate.cake.decorated? && @this_cake_is_already_decorated_message.play && return
    true
  end
end

