class Decorator
  attr_reader :window
  PROCESS_RUNNER_OFFSET = {:x => 25, :y => 45}
  CAKE_PLATE_OFFSET = {:x => 20, :y => 39}
  ACTION_OFFSET = {:x => -10, :y => 20}
  X, Y = 900, 300

  def initialize window
    @window = window
    @body = Gosu::Image.new(@window, 'media/decorator.png', true)
    @buttons = []
    @action_anim = Util::Animator.new(window, 'media/cake-action-anim.png', 120, 100, false, 3, true)
    @this_cake_is_already_decorated_message = Gosu::Sample.new(@window, 'media/this_cake_is_already_decorated.ogg')
    @decoration_process = Util::ProcessRunner.new(@window, 10, X + PROCESS_RUNNER_OFFSET[:x],
                                                               Y + PROCESS_RUNNER_OFFSET[:y]) { make_cake_available_after_decoration }
    @buttons << Button.new(self, {:x => 922, :y => 312, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 28, :dy => 28}, :tree_decoration)
    @buttons << Button.new(self, {:x => 950, :y => 312, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 28, :dy => 28}, :face_decoration)
    @buttons << Button.new(self, {:x => 922, :y => 400, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 28, :dy => 28}, :boat_decoration)
    @buttons << Button.new(self, {:x => 950, :y => 400, :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 28, :dy => 28}, :candle_decoration)
    @buttons.each do |button|
      button.activate
    end
  end

  def update
    @plate && @plate.update_position(X + CAKE_PLATE_OFFSET[:x], Y + CAKE_PLATE_OFFSET[:y])
    @decoration_process.update
  end

  def receive_cake
    verify_cake_is_not_decorated_already || return
    @window.baker.give_plate_to(self)
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
    @window.unregister(plate)
    @plate = plate
  end

  def draw
    @body.draw(X, Y, ZOrder::TABLE_MOUNTED_EQUIPMENTS)
    @show_animation && @action_anim.slide.draw(X + ACTION_OFFSET[:x], Y + ACTION_OFFSET[:y], ZOrder::ACTION_CLOWD)
    @decoration_process.render
    @plate && @plate.render
  end

  private
  def make_cake_available_after_decoration
    @window.register(@plate)
    @action_anim.stop
    @show_animation = false
  end

  def verify_cake_is_not_decorated_already
    plate = @plate || @window.baker.plate
    plate && plate.cake.decorated? && @this_cake_is_already_decorated_message.play && return
    true
  end
end

