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
    
    def initialize(window, caption = 'Bakery')
      @window, @caption = window, caption
      @window.caption = caption
      @window.listner = self
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
  
  def show
    @current_screen = @screens[0].new(@context, @window)
    @current_screen.show
  end
  
  def next
    @current_screen.close
    @current_screen = @screens[@screens.index(@current_screen.class) + 1].new(@context, @window)
    @current_screen.show
  end
  
  def previous
    @current_screen.close
    @current_screen = @screens[@screens.index(@current_screen.class) - 1].new(@context, @window)
    @current_screen.show
  end
end