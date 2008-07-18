class Util::PositionAnimation
  def initialize from, to, within, both_ways = false, callback_map = {}
    @initial_x, @initial_y = from[:x], from[:y]
    @x, @y = @initial_x, @initial_y
    @both_ways = both_ways
    @total_hops_allowed = within
    @anim_length = @total_hops_allowed/(@both_ways ? 2 : 1)
    @x_hop = (to[:x] - from[:x]).to_f/@anim_length
    @y_hop = (to[:y] - from[:y]).to_f/@anim_length
    @hop_cords = [{:x => @x, :y => @y}]
    @handled_callbacks = {}
    @upcoming_callbacks = callback_map || {}
  end
  
  def start 
    reset_callbacks
    @x = @initial_x
    @y = @initial_y
    @anim_length.times do
      @hop_cords << {:x => @x += @x_hop, :y => @y += @y_hop}
    end
    return unless @both_ways
    one_way_counts = @hop_cords.length
    @hop_cords.reverse[1..-1].each do |retracing_coord|
      @hop_cords << retracing_coord
    end
  end
  
  def hop
    if @hop_cords.length > 1
      coord_map = @hop_cords.shift
      anim_left = @hop_cords.length
      execute_callbacks
      execute_callbacks if @hop_cords.length == 1 #executing the corner case.... the last one....
    else
      coord_map = @hop_cords[0]
    end
    return coord_map[:x], coord_map[:y]
  end
  
  private 
  def reset_callbacks
    @handled_callbacks.each_pair do |key, value|
      @upcoming_callbacks[key] = value
    end
    @handled_callbacks = {}
  end
  
  def execute_callbacks
    @upcoming_callbacks.each_pair do |key, value|
      if (@hop_cords.length*100)/@total_hops_allowed < (100 - key)
        value.call 
        @handled_callbacks[key] = value
      end
      @upcoming_callbacks.reject! {|key, value| @handled_callbacks.keys.include?(key)}
    end
  end
end