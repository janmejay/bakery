# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'

class Oven
  def initialize window
    @window = window
    @oven_animator = Util::Animator.new(@window, 'oven_with_cake_plate', 200, 200)
    update_oven_view
  end

  def update_oven_view
    @oven = @oven_animator.slide
  end

  def play_animation
    @oven_animator.run_animation
  end

  def draw
    @oven.draw(530, 0, ZOrder::EQUIPMENTS)
  end
end
