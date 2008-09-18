class StoryPlayer < BakeryWizard::Window
  include Actions
  include Publisher
  include Subscriber
  
  STORY_BASE_DIR = File.join('media', 'stories')
  
  BUTTON_OFFSET = {:x => 930, :y => 680}
  
  def initialize context
    @context = context
    @level = Level.level_details_for @context[:level]
    story_dir = File.join(STORY_BASE_DIR, @level[:story_dir])
    @story_file_names = Dir.entries(story_dir).select { |file_name| file_name =~ /^\d+\.png$/ }.map { |file_name| "#{File.join(story_dir, file_name)}"}
    @cursor = Cursor.new
  end

  def window= window
    @window = window
    @story_series_images = @story_file_names.map { |file_name| Gosu::Image.new(@window, file_name)}
    TextButton.new(self, {:x => BUTTON_OFFSET[:x], :y => BUTTON_OFFSET[:y], :z => 1, :dx => 80, :dy => 80, :image => 'arrow'}, 
      :next_slide, Gosu::Font.new(@window, 'media/hand.ttf', 45), 0xff421111, 'GO!!!').activate
    @cursor.window = self
    next_slide
  end
  
  def next_slide
    (@current_story_slide = @story_series_images.shift) && return
    $wizard.go_to(Shop)
  end
  
  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
  end
  
  def draw
    @cursor.draw
    @current_story_slide.draw(0, 0, 0)
    for_each_subscriber {|sub| sub.render }
  end
end