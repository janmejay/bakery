class StoryPlayer < BakeryWizard::Window
  
  STORY_BASE_DIR = File.join('media', 'stories')
  
  def initialize context
    @context = context
    @level = context[:level]
    @story_series_file_names = Dir.entries(File.join(STORY_BASE_DIR, @level.to_s))
    @story_series_file_names -= ['.', '..']
  end
  
  def window= window
    @window = window
    @story_series_images = @story_series_file_names.map { |file_name| Gosu::Image.new(@window, File.join(STORY_BASE_DIR, @level.to_s))}
  end
  
end