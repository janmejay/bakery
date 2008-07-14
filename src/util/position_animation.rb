class Util::PositionAnimation
  def initialize from, to, within, both_ways = false, callback_map = {}
    @initial_x, @initial_y = from[:x], from[:y]
    @x, @y = @initial_x, @initial_y
    @both_ways = both_ways
    @anim_length = within/(@both_ways ? 2 : 1)
    @x_hop = (to[:x] - from[:x])/within
    @y_hop = (to[:y] - from[:y])/within
    @hop_cords = [{:x => @x, :y => @y}]
    @handled_callbacks = {}
    @upcoming_callbacks = callback_map || {}
  end
  
  def reset 
    reset_callbacks
    @x = @initial_x
    @y = @initial_y
    @anim_length.times do
      @hop_cords << {:x => @x += @x_hop, :y => @y += @y_hop}
    end
    return unless @both_ways
    one_way_counts = @hop_cords.length
    @hop_cords.reverse.each do |retracing_coord|
      @hop_cords << retracing_coord
    end
  end
  
  def hop
    if @hop_cords.length > 1
      coord_map = @hop_cords.shift
      anim_left = @hop_cords.length
      @upcoming_callbacks.each_pair do |key, value|
        if anim_left < key*@anim_length
          value.call 
          @handled_callbacks[key] = value
          @upcoming_callbacks.delete key
        end
      end
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
end