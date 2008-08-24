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
  
  def self.last_played_file_name context
    File.join(File.dirname(__FILE__), '..', 'tmp', "#{context[:name]}_last_played")
  end
  
  def initialize context
    @context = context
    register self
    register Dustbin.new(context[:dustbin])
    context[:showcases].each { |showcase_data| register Showcase.new(showcase_data) }
    @renderables = Set.new
    @dead_entities = []
    @dead_entities << Cursor.new
    @dead_entities << Table.new(context[:table])
    @alive_entities = []
    @context[:ovens].each { |oven_data| @alive_entities << Oven.new(oven_data) }
    @context[:frosters].each { |froster_data| @alive_entities << Froster.new(froster_data) }
    @context[:decorators].each { |decorator_data| @alive_entities << Decorator.new(decorator_data) }
    @alive_entities << @baker = Baker.new
  end
  
  def deactivate_all_buttons
    to_be_unregistered = []
    for_each_subscriber { |subscriber| subscriber.kind_of?(Button) && (to_be_unregistered << subscriber) }
    for_each_subscriber { |subscriber| subscriber.kind_of?(Oven::Button) && (to_be_unregistered << subscriber) }
    unregister *to_be_unregistered
  end
  
  def window= window
    @window = window
    @background_image = Gosu::Image.new(self.window, @context[:floor_view], true)
    for_each_subscriber { |subscriber| subscriber.window = self unless subscriber == self }
    @dead_entities.each { |entity| entity.window = self }
    @alive_entities.each { |entity| entity.window = self }
  end

  def update
    case true
    when button_down?(Gosu::Button::MsLeft): publish(Event.new(:left_click, mouse_x, mouse_y))
    when button_down?(Gosu::Button::MsRight): publish(Event.new(:right_click, mouse_x, mouse_y))
    when button_down?(Gosu::Button::KbEscape):
      deactivate_all_buttons
      dump_shop && $wizard.go_to(GameLoader)
    end
    @alive_entities.each {|entity| entity.update}
    for_each_subscriber {|subscriber| subscriber.perform_updates}
  end
  
  def dump_shop
    File.open(self.class.last_played_file_name(@context), "w") do |handle|
      handle.write(Marshal.dump(self))
    end
  end

  def draw
    @dead_entities.each {|entity| entity.draw}
    @alive_entities.each {|entity| entity.draw}
    for_each_subscriber { |subscriber| subscriber.render}
    @renderables.each { |renderable| @renderables.delete(renderable) unless renderable.render }
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