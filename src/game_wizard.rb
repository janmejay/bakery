class GameWizard
  def initialize
    @screens = []
    @current_screen = nil
    @context = {}
    @window = Bakery::BaseWindow.new(1024, 768, false)
  end
  
  def add screen
    @screens << screen
  end
  
  def accept_as_current_screen current_screen
    raise "TypeMismatch: Expected instance of type #{Bakery::Window.name} got #{current_screen.class.name}" unless current_screen.is_a?(Bakery::Window)
    @current_screen = current_screen
  end
  
  def show
    @screens[0].new(@context, @window)
  end
  
  def next
    @current_screen.close
    @screens[@screens.index(@current_screen.class) + 1].new(@context, @window)
  end
  
  def previous
    @current_screen.close
    @current_screen = @screens[@screens.index(@current_screen.class) - 1].new(@context, @window)
  end
end