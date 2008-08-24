class Util::PositionAnimation
  def initialize from, to, within, both_ways = false, callback_map = {}, callback_receiver = nil
    @initial_x, @initial_y, @final_x, @final_y = from[:x], from[:y], to[:x], to[:y]
    @x, @y = @initial_x, @initial_y
    @both_ways = both_ways
    @total_hops_allowed = within
    @anim_length = @total_hops_allowed/(@both_ways ? 2 : 1)
    @x_hop = (@final_x - @initial_x).to_f/@anim_length
    @y_hop = (@final_y - @initial_y).to_f/@anim_length
    @hop_cords = []
    @handled_callbacks = {}
    @upcoming_callbacks = callback_map || {}
    @callback_receiver = callback_receiver
  end
  
  def start 
    reset_callbacks
    @x = @initial_x
    @y = @initial_y
    insert_hop_cords(@x, @y)
    @anim_length.times { insert_hop_cords(@x += @x_hop, @y += @y_hop)}
    return unless @both_ways
    @hop_cords += @hop_cords.reverse[1..-1]
  end
  
  def hop
    return @both_ways ? [@initial_x, @initial_y] : [@final_x, @final_y] if @hop_cords.empty?
    coord_map = @hop_cords.shift
    anim_left = @hop_cords.length
    execute_callbacks(x = coord_map[:x], y = coord_map[:y])
    return x, y
  end
  
  private 
  def reset_callbacks
    @handled_callbacks.each_pair do |key, value|
      @upcoming_callbacks[key] = value
    end
    @handled_callbacks = {}
  end
  
  def insert_hop_cords x, y
    @hop_cords << {:x => @x, :y => @y}
  end
  
  def execute_callbacks(x, y)
    @upcoming_callbacks.each_pair do |key, value|
      if (@hop_cords.length*100)/@total_hops_allowed < (100 - key)
        value.is_a?(Symbol) && @callback_receiver.send(value, x, y)
        value.is_a?(Proc) && value.call(x, y)
        @handled_callbacks[key] = value
      end
      @upcoming_callbacks.reject! {|key, value| @handled_callbacks.keys.include?(key)}
    end
  end
end