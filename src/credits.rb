class Credits < BakeryWizard::Window
  include Actions
  include Publisher
  include Subscriber
  
  TITLE = "Credits..."
  
  CREDITS = <<-CREDITS
  Bakery is a GNU GPL3 software. I hacked it together, both code and artwork.
    
    Special thanks to Gosu team(http://code.google.com/p/gosu/) for comming up with 
    the sweet little SDL that Bakery uses, GIMP team(without GIMP i couldn't have 
    managed all the artwork), and http://www.toondoo.com(the website I used for 
    creating comic strips).
    
    Used some non-copyrighted images from the web, and I extend my thanks to the 
    authors of those images.
    
    And finally my heartiest thanks to Sweta(my wife), for all the inspiration and 
    support she gave me, without which i could never have invested the long hours 
    it took to create this game.
    
    -Janmejay(developer of the project)
     Blog: http://codehunk.wordpress.com/
  CREDITS
  
  WIDTH, HEIGHT = 620, 768
  
  MESSAGE_OFFSET = REL :x => 15, :y => 80
  
  MODAL_BOX_OFFSET = REL :x => 110, :y => 610
  SHOW_CREDITS_BUTTON_OFFSET = REL :x => 136, :y => 620
  MAIN_MENU_BUTTON_OFFSET = REL :x => 136, :y => 675
  
  MESSAGE_LINE_GAP = 3
  
  BG_OFFSET = REL :x => 100, :y => 84
  
  def initialize *ignore; 
    @message_parts = CREDITS.split(/\s{4}/)
    @cursor = Cursor.new
  end
  
  def window= window
    @window = window
    @cursor.window = self
    @background = Gosu::Image.new(self.window, res('media/game_loader_bg.png'), false)
    @modal_box = Gosu::Image.new(window, res('media/modal_box.png'))
    font = Gosu::Font.new(self.window, res('media/hand.ttf'), 35)
    @message_font = Gosu::Font.new(self.window, res('media/hand.ttf'), 28)
    TextButton.new(self, {:x => SHOW_CREDITS_BUTTON_OFFSET[:x], :y => SHOW_CREDITS_BUTTON_OFFSET[:y], :z => ZOrder::MODAL_BUTTONS, :dx => 348, :dy => 44, :image => :game_loader}, :show_about, font).activate
    TextButton.new(self, {:x => MAIN_MENU_BUTTON_OFFSET[:x], :y => MAIN_MENU_BUTTON_OFFSET[:y], :z => ZOrder::MODAL_BUTTONS, :dx => 348, :dy => 44, :image => :game_loader}, :main_menu, font).activate
    @title = ActionMessage.new font, width/2, 20
    @title.message TITLE, 0xff222222
  end
  
  def show_about
    $wizard.go_to(About)
  end
  
  def main_menu
    $wizard.go_to(WelcomeMenu)
  end
  
  def update
    if button_down? Gosu::Button::MsLeft
      publish(Event.new(:left_click, mouse_x, mouse_y))
    elsif button_down? Gosu::Button::MsRight
      publish(Event.new(:right_click, mouse_x, mouse_y))
    end
    for_each_subscriber {|subscriber| subscriber.perform_updates}
  end
  
  def draw
    @background.draw(BG_OFFSET[:x], BG_OFFSET[:y], 0)
    @title.draw
    @message_parts.each_with_index do |message_part, index|
      @message_font.draw(message_part, MESSAGE_OFFSET[:x], MESSAGE_OFFSET[:y] + (MESSAGE_LINE_GAP + @message_font.height)*index, 1, 1.0, 1.0, 0xff000000)
    end
    @cursor.draw
    for_each_subscriber { |subscriber| subscriber.render}
    @modal_box.draw(MODAL_BOX_OFFSET[:x], MODAL_BOX_OFFSET[:y], ZOrder::MODAL_PANES)
  end
end
