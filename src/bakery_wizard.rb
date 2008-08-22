class BakeryWizard
  
  class BaseWindow < Gosu::Window
    
    WIDTH, HEIGHT = 1024, 768
    
    def listner= listner
      @listner = listner
    end
  
    def draw
      draw_quad(0, 0, 0xffffffff, WIDTH, 0, 0xffffffff, 0, HEIGHT, 0xffffffff, WIDTH, HEIGHT, 0xffffffff)
      @listner && @listner.draw
    end
    
    def update
      @listner && @listner.update
    end
    
  end
  
  class Window

    def self.REL map
      {:x => (BaseWindow::WIDTH - self::WIDTH)/2 + map[:x], :y => (BaseWindow::HEIGHT - self::HEIGHT)/2 + map[:y]}
    end
    
    def self.width= width
      put "CALLED....."
      @@width = width
    end
    
    def self.height= height
      @@height = height
    end
    
    def initialize(window, caption = 'Bakery')
      @window, @caption = window, caption
      @window.caption = caption
      @window.listner = self
      $wizard.accept_as_current_screen self
    end
    
    def update; end
    def draw; end
    
    def window
      @window
    end
    
    def method_missing *args
      @window.send(*args)
    end
  end
  
  def initialize
    @screens = []
    @current_screen = nil
    @context = {}
    @window = BaseWindow.new(1024, 768, false)
  end
  
  def add screen
    @screens << screen
  end
  
  def accept_as_current_screen current_screen
    raise "TypeMismatch: Expected instance of type #{Window.name} got #{current_screen.class.name}" unless current_screen.is_a?(Window)
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