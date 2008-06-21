# User: janmejay.singh
# Time: 20 Jun, 2008 7:44:35 PM
class Util::Animator
  def initialize window, strip_file_name, tile_width, tile_heights, play_both_ways = false, chunk_slice_width = 1, &callback_on_completion
    @slides = Gosu::Image::load_tiles(window, strip_file_name, tile_width, tile_heights, true)
    @forward, @running = true, false
    @play_both_ways = play_both_ways
    @callback_on_completion = callback_on_completion || proc {}
    @chunk_slice_width = chunk_slice_width
    @slices_done_for_this_chunk, @chunks_finished = 0, 0
  end

  def start
    @forward = true
    @chunks_finished = 0
    @running = true
  end

  def slide
    return @slides[0] unless @running
    update_chunk_state
    slide = @slides[@chunks_finished - 1]
    update_running_status
    slide
  end

  private

  def update_chunk_state
    if (@slices_done_for_this_chunk += 1) >= @chunk_slice_width
      @slices_done_for_this_chunk = 0
      @chunks_finished += 1
    elsif @chunks_finished + 1 >= @slides.length
      @running = false
      @chunks_finished = 0
    end
  end

  def update_running_status
    @running = (@chunks_finished < @slides.length)
  end
end
