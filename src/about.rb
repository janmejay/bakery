class About < BakeryWizard::Window
  include Actions
  include Publisher
  include Subscriber
  
  TITLE = "Thanks a lot for playing Bakery....."
  
  MESSAGE = <<-MESSAGE
Bakery is a free and open source game. I created Bakery
    to give back FOSS community, what i have been taking
    from it. I believe that everyone who uses Open Source
    Software has a responsibility to go back and contribute
    and this is the way I choose to do it.
    
  If you like the game and want to contribute in terms of
    code, artwork, ideas or feedback, you are welcome to do so.
    The project is hosted at http://github.com/janmejay/bakery.
    
  Finally... this game is dedicated to Sweta(my wife). without
    whose love, patience and motivation i couldn't have invested
    all the time and effort i did to complete Bakery.
    
  I hope you are enjoying/enjoyed playing the game...
  MESSAGE
  
  WIDTH, HEIGHT = 420, 700
  
  TITLE_OFFSET = REL :x => 0, :y => 0
  MESSAGE_OFFSET = REL :x => 0, :y => 50
  
  MODAL_BOX_OFFSET = REL :x => 10, :y => 550
  SHOW_CREDITS_BUTTON_OFFSET = REL :x => 36, :y => 560
  MAIN_MENU_BUTTON_OFFSET = REL :x => 36, :y => 615
  
  MESSAGE_LINE_GAP = 3
  
  BG_OFFSET = REL :x => 0, :y => 50
  
  def initialize *ignore
    @cursor = Cursor.new
    @message_parts = MESSAGE.split(/\s{4}/)
  end
  
  def window= window
    @window = window
    @cursor.window = self
    @background = Gosu::Image.new(self.window, 'media/game_loader_bg.png', false)
    @modal_box = Gosu::Image.new(window, 'media/modal_box.png')
    @font = Gosu::Font.new(self.window, 'media/hand.ttf', 35)
    @message_font = Gosu::Font.new(self.window, 'media/hand.ttf', 28)
    TextButton.new(self, {:x => SHOW_CREDITS_BUTTON_OFFSET[:x], :y => SHOW_CREDITS_BUTTON_OFFSET[:y], :z => ZOrder::MODAL_BUTTONS, :dx => 348, :dy => 44, :image => :game_loader}, :show_credits, @font).activate
    TextButton.new(self, {:x => MAIN_MENU_BUTTON_OFFSET[:x], :y => MAIN_MENU_BUTTON_OFFSET[:y], :z => ZOrder::MODAL_BUTTONS, :dx => 348, :dy => 44, :image => :game_loader}, :main_menu, @font).activate
  end
  
  def show_credits
    $wizard.go_to(Credits)
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
    @font.draw(TITLE, TITLE_OFFSET[:x], TITLE_OFFSET[:y], 1, 1.0, 1.0, 0xff222222)
    @message_parts.each_with_index do |message_part, index|
      @message_font.draw(message_part, MESSAGE_OFFSET[:x], MESSAGE_OFFSET[:y] + (MESSAGE_LINE_GAP + @message_font.height)*index, 1, 1.0, 1.0, 0xff000000)
    end
    @cursor.draw
    for_each_subscriber { |subscriber| subscriber.render}
    @modal_box.draw(MODAL_BOX_OFFSET[:x], MODAL_BOX_OFFSET[:y], ZOrder::MODAL_PANES)
  end
end