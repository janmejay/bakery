require 'cursor'
require 'baker'
require 'table'
require 'dustbin'
require 'oven'
require 'zorder'
require 'util/actions'
require 'util/process_runner'

class GameWindow < Gosu::Window
  attr_reader :baker
  include Actions
  include Publisher
  include Subscriber
  
  def initialize
    super(1024, 768, false)
    self.caption = "Bakery"
    
    @background_image = Gosu::Image.new(self, "media/floor.png", true)
    
    @cursor = Cursor.new(self)
    @baker = Baker.new(self)
    @table = Table.new(self)
    register self
    register Oven.new(self)
    register Dustbin.new(self)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
    @baker.update
    for_each_subscriber {|subscriber| subscriber.perform_updates}
  end

  def draw
    @cursor.draw
    @baker.draw
    @table.draw
    for_each_subscriber { |subscriber| subscriber.render}
    @font.draw("Score: #{mouse_x} X #{mouse_y}", 10, 10, ZOrder::MESSAGES, 1.0, 1.0, 0xffffff00)
  end
  
  def render
    @background_image.draw(0, 0, zindex)
  end
  
  def can_consume?(event)
    event.propagatable
  end
  
  def handle(e)
    @baker.walk_down_and_trigger e.x, e.y
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
  
  def zindex
    ZOrder::BACKGROUND
  end
end