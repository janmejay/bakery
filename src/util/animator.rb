# User: janmejay.singh
# Time: 20 Jun, 2008 7:44:35 PM
class Util::Animator
  def initialize window, strip_file_name, tile_width, tile_heights, play_both_ways = false, chunk_slice_width = 1, &callback_on_completion
    @slides = Gosu::Image::load_tiles(window, strip_file_name, tile_width, tile_heights, true)
    @play_both_ways = play_both_ways
    @callback_on_completion = callback_on_completion || proc {}
    @chunk_slice_width = chunk_slice_width
    create_animated_sequence
    @current_anim_sequence = []
  end

  def start
    @current_anim_sequence = @animated_sequence.dup
  end

  def slide
    @current_anim_sequence.empty? ? @slides[0] : @current_anim_sequence.shift
  end

  private
  def create_animated_sequence
    @animated_sequence = []
    @slides.each do |slide|
      @chunk_slice_width.times do
        @animated_sequence << slide
      end
    end
    return unless @play_both_ways
    @slides[0..-2].reverse.each do |slide| #second_last to first iteration
      @chunk_slice_width.times do
        @animated_sequence << slide
      end
    end
  end
end
