# User: janmejay.singh
# Time: 20 Jun, 2008 7:44:35 PM
class Util::Animator
  def initialize window, strip_name, tile_width, tile_heights, play_both_ways = false, chunk_slice_width = 1, &callback_on_completion
    @slides = Gosu::Image::load_tiles(window, "media/#{strip_name}.png", tile_width, tile_heights, true)
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
    do_slice_calculation if @running
    @slide = @slides[@chunks_finished]
    update_state if @running
    @slide
  end

  private

  def update_state
    @play_both_ways ? update_state_two_way : update_state_one_way
    @running = (@chunks_finished != 0)
  end

  def update_state_two_way
    @forward = @forward && (@chunks_finished + 1 < @slides.length)
    @chunks_finished += (@forward ? 1 : -1)
  end

  def update_state_one_way
    @chunks_finished = (@chunks_finished + 1 < @slides.length) ? @chunks_finished + 1 : 0
  end

  def do_slice_calculation
    if @slices_done_for_this_chunk < @chunk_slice_width
      @slices_done_for_this_chunk += 1
    elsif (@chunks_finished += 1) < @slides.length
      @slices_done_for_this_chunk = 0
      @slide = @slides[@chunks_finished]
    else
      @slices_done_for_this_chunk = 0
      @chunks_finished = 0
    end
  end
end
