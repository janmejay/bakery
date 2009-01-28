# User: janmejay.singh
# Time: 20 Jun, 2008 7:44:35 PM
class Util::Animator
  def initialize strip_file_name, tile_width, tile_heights, options = {}, &block
    @tile_width, @tile_heights = tile_width, tile_heights
    @strip_file_name = strip_file_name
    options = {:play_both_ways => false, :chunk_slice_width => 1, :run_indefinitly => false}.merge(options)
    @play_both_ways = options[:play_both_ways]
    @callback_on_completion = block || options[:call_on_completion]
    @callback_receiver = options[:callback_receiver]
    @chunk_slice_width = options[:chunk_slice_width]
    @run_indefinitly = options[:run_indefinitly]
  end
  
  def window= window
    @slides = Gosu::Image::load_tiles(window, @strip_file_name, @tile_width, @tile_heights, true)
    create_animated_sequence
    @running ? start : (@current_anim_sequence = [])
  end

  def attach_sound sample
    @sample = sample
  end

  def start
    @current_anim_sequence = @animated_sequence.dup
    @running = true
  end

  def stop
    @current_anim_sequence = []
    @sample && @sample.stop
    @running = false
  end

  def slide
    @current_anim_sequence.empty? && stop
    @running && @sample && (@sample.playing? || @sample.play)
    @running ? current_slide : @slides[0]
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
