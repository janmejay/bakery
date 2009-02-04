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
    @callback_map = options[:callback_map]
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
    @progress = 0
  end

  def running?
    @running
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
    set_anim_length
    return unless @play_both_ways
    @slides[0..-2].reverse.each do |slide| #second_last to first iteration
      @chunk_slice_width.times do
        @animated_sequence << slide
      end
    end
    set_anim_length
  end

  def set_anim_length
    @anim_total_length = @animated_sequence.length
  end

  def current_slide
    current_slide = @current_anim_sequence.shift
    check_and_execute_mature_callbacks
    if @run_indefinitly
      @current_anim_sequence.push(current_slide) 
    elsif @current_anim_sequence.empty? 
      @callback_on_completion.is_a?(Proc) && @callback_on_completion.call
      @callback_on_completion.is_a?(Symbol) && @callback_receiver.send(@callback_on_completion)
    end
    current_slide
  end

  def check_and_execute_mature_callbacks
    (@callback_map.nil? || @callback_map.empty? || @callback_receiver.nil?) && return
    progress_percentage, last_check_progress_percentage = @progress*100/@anim_total_length, (@progress - 1)*100/@anim_total_length
    @callback_map.each do |call_at, callback|
      (call_at < progress_percentage) && (call_at >= last_check_progress_percentage) && @callback_receiver.send(callback)
    end
    @progress += 1
    (@progress >= @animated_sequence.length) && @progress = 0
  end
end
