# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'

class Oven
  def initialize window
    @window = window
    @oven_animator = Util::Animator.new(@window, 'media/oven_with_cake_plate.png', 200, 200, true)
    update_oven_view
  end

  def update_oven_view
    @oven = @oven_animator.slide
  end

  def play_animation
    @oven_animator.start
  end

  def draw
    @oven.draw(530, 0, ZOrder::EQUIPMENTS)
  end
end
