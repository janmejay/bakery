# User: janmejay.singh
# Time: 20 Jun, 2008 7:44:35 PM
class Util::Animator
  def initialize window, strip_file_name, tile_width, tile_heights, options = {}, &block
    options = {:play_both_ways => false, :chunk_slice_width => 1, :run_indefinitly => false}.merge(options)
    @slides = Gosu::Image::load_tiles(window, strip_file_name, tile_width, tile_heights, true)
    @play_both_ways = options[:play_both_ways]
    @callback_on_completion = block || options[:call_on_completion]
    @callback_receiver = options[:callback_receiver]
    @chunk_slice_width = options[:chunk_slice_width]
    @run_indefinitly = options[:run_indefinitly]
    create_animated_sequence
    @current_anim_sequence = []
  end

  def start
    @current_anim_sequence = @animated_sequence.dup
  end

  def stop
    @current_anim_sequence = []
  end

  def slide
    @current_anim_sequence.empty? ? @slides[0] : current_slide
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

  def current_slide
    current_slide = @current_anim_sequence.shift
    if @run_indefinitly
      @current_anim_sequence.push(current_slide) 
    elsif @current_anim_sequence.empty? 
      @callback_on_completion.is_a?(Proc) && @callback_on_completion.call
      @callback_on_completion.is_a?(Symbol) && @callback_receiver.send(@callback_on_completion)
    end
    current_slide
  end
end
