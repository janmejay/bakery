class GameWizard
  def initialize
    @screens = []
    @current_screen = nil
    @context = {}
  end
  
  def add screen
    @screens << screen
  end
  
  def show
    @current_screen = @screens[0].new(@context)
    @current_screen.show
  end
  
  def next
    @current_screen.close
    @current_screen = @screens[@screens.index(@current_screen.class) + 1].new(@context)
    @current_screen.show
  end
  
  def previous
    @current_screen.close
    @current_screen = @screens[@screens.index(@current_screen.class) - 1].new(@context)
    @current_screen.show
  end
end