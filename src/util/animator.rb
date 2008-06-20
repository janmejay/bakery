# User: janmejay.singh
# Time: 20 Jun, 2008 7:44:35 PM
class Util::Animator
  def initialize window, strip_name, tile_width, tile_heights
    @slides = Gosu::Image::load_tiles(window, "media/#{strip_name}.png", tile_width, tile_heights, true)
    @current_tile_index = 0
    @forward = true
    @running = false
  end

  def run_animation
    @forward = true
    @current_tile_index = 0
    @running = true
  end

  def slide
    puts "Serving slide : #{@current_tile_index}"
    slide = @slides[@current_tile_index]
    update_state if @running
    puts "Slide index: #{@current_tile_index}, forward: #{@forward}, running: #{@running}"
    slide
  end

  private

  def update_state
    @forward = @forward && (@current_tile_index + 1 < @slides.length)
    @current_tile_index += (@forward ? 1 : -1)
    @running = (@current_tile_index != 0)
  end
end
