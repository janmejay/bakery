class Decorator
  
  include AliveAsset
  include Oven::Plate::Handler
  include OneCakeHolder
  
  PROCESS_RUNNER_OFFSET = {:x => 25, :y => 45}
  CAKE_PLATE_OFFSET = {:x => 20, :y => 39}
  ACTION_OFFSET = {:x => -10, :y => 20}
  BUTTON_OFFSETS = [
      {:x => 22, :y => 12}, {:x => 50, :y => 12},
      {:x => 22, :y => 100}, {:x => 50, :y => 100}
    ]
    
  COST = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'data', 'returns.yml'))[:decoration]

  def initialize context_decorator_data
    @context_decorator_data = context_decorator_data
    @x, @y = context_decorator_data[:x], context_decorator_data[:y]
    @buttons = []
    @action_anim = Util::Animator.new(res('media/cake-action-anim.png'), 120, 100, :chunk_slice_width => 3, :run_indefinitly => true)
    @decoration_process = Util::ProcessRunner.new(10, @x + PROCESS_RUNNER_OFFSET[:x],
                                                               @y + PROCESS_RUNNER_OFFSET[:y], :make_cake_available_after_decoration, self)
  end
  
  def window= shop_window
    @shop_window = shop_window
    @body = Gosu::Image.new(@shop_window.window, res(@context_decorator_data[:machine_view]), true)
    @action_anim.window = @shop_window.window
    @decoration_process.window = @shop_window.window
    @this_cake_is_already_decorated_message = Gosu::Sample.new(@shop_window.window, res('media/this_cake_is_already_decorated.ogg'))
    @cookies_can_not_be_decorated_message = Gosu::Sample.new(@shop_window.window, res('media/cookies_can_not_be_decorated.ogg'))
    @decoration_process.attach_sound(Gosu::Song.new(@shop_window.window, res('media/decorator_sound.ogg')))
    (@decoration_types = @context_decorator_data[:buttons]).each_with_index do |button, index|
      GameButton.new(self, {:x => @x + BUTTON_OFFSETS[index][:x], :y => @y + BUTTON_OFFSETS[index][:y], 
        :z => ZOrder::TABLE_MOUNTED_CONTROLS, :dx => 28, :dy => 28}, button).activate
    end
  end
  
  def build_sample_on sample_plate
    sample_plate.cake.put_decoration(@decoration_types[rand(@decoration_types.length)].to_s.gsub(/_decoration/, '').to_sym)
    sample_plate
  end
  
  def window
    @shop_window
  end

  def update
    @plate && @plate.update_position(@x + CAKE_PLATE_OFFSET[:x], @y + CAKE_PLATE_OFFSET[:y])
    @decoration_process.update
  end

  def receive_cake
    @shop_window.baker.give_plate_to(self) || return
    @action_anim.start
    @decoration_process.start
    @show_animation = true #REFACTOR ME!!!! put me in the animator
  end

  def before_accepting_plate plate
    (verify_cake_is_not_decorated_already(plate) && verify_doesnt_have_a_cake_already) || return
  end

  def after_accepting_plate *ignore
    @shop_window.unregister(@plate)
  end

  def candle_decoration *ignore
    receive_cake && @plate.cake.put_decoration(:candle)
  end                               
                                    
  def tree_decoration *ignore
    receive_cake && @plate.cake.put_decoration(:tree)
  end                               
                                    
  def boat_decoration *ignore
    receive_cake && @plate.cake.put_decoration(:boat)
  end                               
                                    
  def face_decoration *ignore
    receive_cake && @plate.cake.put_decoration(:face)
  end
  
  def lips_decoration *ignore
    receive_cake && @plate.cake.put_decoration(:lips)
  end                               
                                    
  def knot_decoration *ignore
    receive_cake && @plate.cake.put_decoration(:knot)
  end                               
                                    
  def flower_decoration *ignore
    receive_cake && @plate.cake.put_decoration(:flower)
  end                               
                                    
  def glass_decoration *ignore
    receive_cake && @plate.cake.put_decoration(:glass)
  end

  def give_plate_to baker
    baker.accept_plate(@plate) && @plate = nil
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

  def verify_cake_is_not_decorated_already plate
    plate && plate.has_cookies? && @cookies_can_not_be_decorated_message.play && return
    plate && plate.cake.decorated? && @this_cake_is_already_decorated_message.play && return
    true
  end
end

