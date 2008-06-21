# User: janmejay.singh
# Time: 21 Jun, 2008 7:04:49 AM
require File.join(File.dirname(__FILE__), 'animator')

class Util::ProcessRunner
  def initialize window, process_chunk_slice_width, at_x, at_y, &callback_on_completion
    @animation = Util::Animator.new(window, 'completion', 50, 50, false, process_chunk_slice_width) do
      @running = false
      callback_on_completion
    end
    @x, @y = at_x, at_y
    @image = @animation.slide
  end

  def start
    @animation.start
    @running = true
  end

  def update
    @image = @animation.slide
  end

  def draw
    @image.draw(@x, @y, ZOrder::PROCESSING) if @running
  end
end