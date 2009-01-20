# User: janmejay.singh
# Time: 21 Jun, 2008 7:04:49 AM
require File.join(File.dirname(__FILE__), 'animator')

class Util::ProcessRunner
  def initialize process_chunk_slice_width, at_x, at_y, callback_method, callback_receiver
    @callback_method = callback_method
    @callback_receiver = callback_receiver
    @animation = Util::Animator.new(res('media/completion.png'), 50, 50, :chunk_slice_width => process_chunk_slice_width, :callback_receiver => self, :call_on_completion => :process_finished)
    @x, @y = at_x, at_y
  end
  
  def window= window
    @animation.window = window
    @image = @animation.slide
  end
  
  def process_finished
    @running = false
    @callback_receiver.send(@callback_method)
  end

  def start
    @animation.start
    @running = true
  end
  
  def running?
    @running
  end

  def update
    @image = @animation.slide
  end

  def render
    @image.draw(@x, @y, ZOrder::PROCESSING) if @running
  end
end
