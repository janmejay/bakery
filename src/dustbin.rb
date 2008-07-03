# User: janmejay.singh
# Time: 20 Jun, 2008 3:54:15 PM

require 'util/animator'

class Dustbin
  def initialize window
    @window = window
    @dustbin_animator = Util::Animator.new(@window, 'media/opening_dustbin.png', 150, 120, true)
    update_view
  end

  def update_view
    @dustbin = @dustbin_animator.slide
  end

  def open
    @dustbin_animator.start
  end

  def draw
    @dustbin.draw(790, 150, ZOrder::UNDER_TABLE_EQUIPMENTS)
  end
end
