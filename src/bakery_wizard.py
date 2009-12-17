import pygame
from util import actions

class BaseWindow(actions.Publisher):
    def __init__(self):
        actions.Publisher.__init__(self)

    def has_bg(self):
        return hasattr(self, 'bg')

    def load(self, screen):
        self.screen = screen
        self.sprites = pygame.sprite.LayeredDirty()
        bg_expanded = self.screen.copy()
        bg_expanded.fill((255, 255, 255))
        if self.has_bg(): 
            rect = self.bg.get_rect()
            rect.center = bg_expanded.get_rect().center
            bg_expanded.blit(self.bg, (rect.left, rect.top))
        self.bg = bg_expanded

    def center_xy(self, surface):
        width, height = self.screen.get_size()
        surface_width, surface_height = surface.get_size()
        return (width - surface_width)/2, (height - surface_height)/2

    def draw(self):
        self.sprites.draw(self.screen, self.bg)
        
class BakeryWizard:
    def __init__(self):
        self.window_changed = False
        self.continue_game_loop = False
        pygame.init()
        self.screen = pygame.display.set_mode((1024, 768))

    def show(self, window):
        self.current_window = window
        self.current_window.load(self.screen)
        self.continue_game_loop = True
        self.window_changed = True

    def continue_looping(self):
        return self.continue_game_loop

    def stop(self):
        self.continue_game_loop = False

    def start(self):
        while self.continue_looping():
            self.current_window.draw()
            for action in actions.actionsFor(pygame.event.get()):
                self.current_window.publish(action)
            pygame.display.flip()


# class BakeryWizard():

#     class BaseWindow():
#         WIDTH, HEIGHT = 1024, 768
#         def set_listner(self, listner):
#             self.__listner = listner

#         def draw(self):
#             draw_quad(0, 0, 0xffffffff, self.__class__.WIDTH, 0, 0xffffffff, 0, self.__class__.HEIGHT, 0xffffffff, self.__class__.WIDTH, self.__class__.HEIGHT, 0xffffffff)
#             self.__stop_display or (self.__listner && self.__listner.draw)

#         def update(self):
#             self.__stop_display or (self.__listner && self.__listner.update)

#         def show(self):
#             self.__stop_display = False

#         def close(self):
#             self.__stop_display = True

#   class Window():
#     class Buildable():
#       def build context, window, options = {}
#         $logger.debug("Building window #{window.inspect} with options => #{options.inspect} and context => #{context.inspect}")
#         options[:params] ||= {}
#         options[:pre_params] ||= {}
#         options[:callbacks] ||= []
#         instance = options.has_key?(:from_file) ? Marshal.load(File.open(options[:from_file], 'r').read) : new(context)
#         options[:pre_params].each { |option_name, option_value| instance.respond_to?("#{option_name}=") && instance.send("#{option_name}=", option_value) }
#         instance.respond_to?(:ready_for_setting_window) && instance.ready_for_setting_window
#         instance.window= window
#         window.caption = options[:caption] || 'Bakery'
#         window.listner = instance
#         options[:params].each { |option_name, option_value| instance.respond_to?("#{option_name}=") && instance.send("#{option_name}=", option_value) }
#         Array(options[:callbacks]).each { |callback_name| instance.respond_to?(callback_name) && instance.send(callback_name) }
#         instance.respond_to?(:ready_for_update_and_render) && instance.ready_for_update_and_render
#         $logger.info("Window build was successful")
#         instance

#     def self.REL map
#       {:x => (BaseWindow::WIDTH - self::WIDTH)/2 + map[:x], :y => (BaseWindow::HEIGHT - self::HEIGHT)/2 + map[:y]}
#     end

#     def self.inherited subclass
#       subclass.extend Buildable
#     end

#     def update; end
#     def draw; end

#     def window
#       @window
#     end

#     def method_missing *args
#       @window.send(*args)
#     end
#   end

#   class WindowChangeRequest
#     attr_reader :requested_screen, :arguments
#     def initialize requested_screen, arguments
#       @requested_screen = requested_screen
#       @arguments = arguments
#     end

#     def to_s
#       "(requested_screen => #{requested_screen.inspect}, arguments => #{arguments.inspect})"
#     end
#   end

#   UN_NOTICABLE_WAIT_TIME = 0.4 #seconds

#   def initialize
#     @screens = []
#     @current_screen = nil
#     @context = {}
#     @window = BaseWindow.new(1024, 768, false)
#     Signal.trap('USR1') do
#       @window_change_request && process_window_change_req
#     end
#     @window_change_in_pregress = Mutex.new
#   end

#   def add screen
#     @screens << screen
#   end

#   def go_to requested_screen, *args
#     window_change_req = WindowChangeRequest.new(requested_screen, args)
#     @window_change_request && $logger.debug("Ignoring window change request#{window_change_req}. Another request#{@window_change_request} is in progress.") && return
#     $logger.debug("Will try to add a new window change request#{window_change_req} NOW.")
#     @window_change_in_pregress.synchronize do
#       $logger.debug("Adding Window change request for #{window_change_req}")
#       @window_change_request = window_change_req
#     end
#     Process.kill("USR1", Process.pid)
#   end

#   def maintain_active_display!
#     $logger.debug("Display Maintainer: enabling display window...")
#     @current_screen.show
#   end

#   private
#   def process_window_change_req
#     @window_change_in_pregress.synchronize do
#       resurrect_active_display
#     end
#     $logger.debug("Returning the stack(was waiting for thread #{@active_display_thread.inspect}).")
#   end

#   def resurrect_active_display
#     request_id = "[#{@window_change_request.inspect}] -> "
#     $logger.debug("#{request_id}Display resurrection initiated")
#     $logger.debug("#{request_id}Existing display refresh loop stoped")
#     arguments = [@context, @window] + @window_change_request.arguments
#     @current_screen = @screens.find { |screen| screen == @window_change_request.requested_screen }.build(*arguments)
#     $logger.debug("#{request_id} Killed active display")
#     @window_change_request = nil
#   end
# end
