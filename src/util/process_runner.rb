# User: janmejay.singh
# Time: 21 Jun, 2008 7:04:49 AM
class Util::ProcessRunner
  def initialize window, process_chunk_slice_width, at_x, at_y, &callback_on_completion
    @images = Gosu::Image.load_tiles(window, "media/completion.png", 50, 50, true)
    @x, @y = at_x, at_y
    @callback_on_completion = callback_on_completion || proc {}
    @chunk_slice_width = process_chunk_slice_width
    @slices_done_for_this_chunk, @chunks_finished = 0, 0
    @running = false
    @image = @images[0]
  end

  def run_animation
    @running = true
  end

  def update
    if @slices_done_for_this_chunk < @chunk_slice_width
      @slices_done_for_this_chunk += 1
    elsif (@chunks_finished += 1) < @images.length
      @slices_done_for_this_chunk = 0
      @image = @images[@chunks_finished]
    else
      @slices_done_for_this_chunk = 0
      @chunks_finished = 0
      @running = false
    end
  end

  def draw
    @image.draw(@x, @y, ZOrder::PROCESSING) if @running
  end
end