require 'cursor'
require 'baker'
require 'table'
require 'dustbin'
require 'oven'
require 'zorder'
require 'froster'
require 'showcase'
require 'decorator'
require 'util/actions'
require 'util/process_runner'
require File.join(File.dirname(__FILE__), "common", "game_button")
require 'set'

class Shop < BakeryWizard::Window
  attr_reader :baker
  include Actions
  include Publisher
  include Subscriber
  
  def initialize context, window
    super(window)
    @context = context

    @background_image = Gosu::Image.new(self.window, "media/floor.png", true)
    register self
    register Dustbin.new(self)
    register Showcase.new(self)
    @renderables = Set.new
    @dead_entities = []
    @dead_entities << Cursor.new(self)
    @dead_entities << Table.new(self)
    @alive_entities = []
    @context[:ovens].each { |oven_data| @alive_entities << Oven.new(self, oven_data) }
    @context[:frosters].each { |froster_data| @alive_entities << Froster.new(self, froster_data) }
    @alive_entities << Decorator.new(self)
    @alive_entities << @baker = Baker.new(self)
    @font = Gosu::Font.new(window, Gosu::default_font_name, 20)
    show
  end

  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
    @alive_entities.each {|entity| entity.update}
    for_each_subscriber {|subscriber| subscriber.perform_updates}
  end

  def draw
    @dead_entities.each {|entity| entity.draw}
    @alive_entities.each {|entity| entity.draw}
    for_each_subscriber { |subscriber| subscriber.render}
    @renderables.each { |renderable| @renderables.delete(renderable) unless renderable.render }
    @font.draw("Score: #{mouse_x} X #{mouse_y}", 10, 10, ZOrder::MESSAGES, 1.0, 1.0, 0xaaffffff)
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
  
  def keep_rendering_until_returns_nil renderable
    @renderables << renderable
  end
  
  def zindex
    ZOrder::BACKGROUND
  end
end