class Television
  
  include DeadAsset
  
  def initialize context_tv_data
     @context_tv_data = context_tv_data
     @x, @y = @context_tv_data[:x], @context_tv_data[:y]
     @theta = @context_tv_data[:theta]
  end
  
  def window= shop_window
    @shop_window = shop_window
    @tv_table = Gosu::Image.new(@shop_window.window, res(@context_tv_data[:top_view]), true)
  end
  
  def draw
    @tv_table.draw_rot(@x, @y, ZOrder::TV, @theta)
  end
end
