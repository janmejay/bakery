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
    
    module Buildable
      def build context, window, from = nil, caption = 'Bakery'
        instance = from ? Marshal.load(File.open(from, 'r').read) : new(context)
        instance.window= window
        window.caption = caption
        window.listner = instance
        instance
      end
    end

    def self.REL map
      {:x => (BaseWindow::WIDTH - self::WIDTH)/2 + map[:x], :y => (BaseWindow::HEIGHT - self::HEIGHT)/2 + map[:y]}
    end
    
    def self.inherited subclass
      subclass.extend Buildable
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
  
  def go_to requested_screen, *args
    @current_screen && @current_screen.close
    arguments = [@context, @window] + args
    @current_screen = @screens.find { |screen| screen == requested_screen }.build(*arguments)
    @current_screen.show
  end
end