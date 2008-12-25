require 'timeout'

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
      def build context, window, options = {}
        $logger.debug("Building window #{window.inspect} with options => #{options.inspect} and context => #{context.inspect}")
        options[:params] ||= []
        options[:pre_params] ||= []
        instance = options.has_key?(:from_file) ? Marshal.load(File.open(options[:from_file], 'r').read) : new(context)
        options[:pre_params].each { |option_name, option_value| instance.respond_to?("#{option_name}=") && instance.send("#{option_name}=", option_value) }
        instance.respond_to?(:ready_for_setting_window) && instance.ready_for_setting_window
        instance.window= window
        window.caption = options[:caption] || 'Bakery'
        window.listner = instance
        options[:params].each { |option_name, option_value| instance.respond_to?("#{option_name}=") && instance.send("#{option_name}=", option_value) }
        instance.respond_to?(:ready_for_update_and_render) && instance.ready_for_update_and_render
        $logger.debug("Window build was successful")
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
  
  class WindowChangeRequest
    attr_reader :requested_screen, :arguments
    def initialize requested_screen, arguments
      @requested_screen = requested_screen
      @arguments = arguments
    end
    
    def to_s
      "(requested_screen => #{requested_screen.inspect}, arguments => #{arguments.inspect})"
    end
  end
  
  UN_NOTICABLE_WAIT_TIME = 0.4 #seconds
  
  def initialize
    @screens = []
    @current_screen = nil
    @context = {}
    @window = BaseWindow.new(1024, 768, false)
    Signal.trap('USR1') do
      @window_change_request && process_window_change_req
    end
    @window_change_in_pregress = Mutex.new
  end
  
  def add screen
    @screens << screen
  end
  
  def go_to requested_screen, *args
    window_change_req = WindowChangeRequest.new(requested_screen, args)
    @window_change_request && $logger.debug("Ignoring window change request#{window_change_req}. Another request#{@window_change_request} is in progress.") && return
    $logger.debug("Will try to add a new window change request#{window_change_req} NOW.")
    @window_change_in_pregress.synchronize do
      $logger.debug("Adding Window change request for #{window_change_req}")
      @window_change_request = window_change_req
    end
    Process.kill("USR1", Process.pid)
  end
  
  def maintain_active_display!
    loop do
      $logger.debug("Display Maintainer: (re)enabling display window...")
      @active_display_thread = Thread.new { @current_screen.show }
      @active_display_thread.join
    end
  rescue
    $logger.error("Display Maintainer: Unexpected: The display maintainer died. Dumping killing stack's trace to #{$death_trace_file}")
    File.open($death_trace_file, 'w') { |h| h.write($!.backtrace.join("\n")) }
    raise $!
  end
  
  private 
  def process_window_change_req
    @window_change_in_pregress.synchronize do 
      resurrect_active_display
    end
    $logger.debug("Returning the stack(was waiting for thread #{@active_display_thread.inspect}).")
  end
  
  def resurrect_active_display
    request_id = "[#{@window_change_request.inspect}] -> "
    $logger.debug("#{request_id}Display resurrection initiated")
    @current_screen && @current_screen.close
    $logger.debug("#{request_id}Existing display refresh loop stoped")
    arguments = [@context, @window] + @window_change_request.arguments
    @current_screen = @screens.find { |screen| screen == @window_change_request.requested_screen }.build(*arguments)
    @active_display_thread && @active_display_thread.kill
    $logger.debug("#{request_id} Killed active display")
    @window_change_request = nil
  end
end