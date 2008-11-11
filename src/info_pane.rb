
class InfoPane
  
  include AliveAsset
  
  def initialize shop
    @shop = shop
  end
  
  def update
    @baker_goal_message.message "Baker's Goal: #{@shop.level.required_earnings}", 0xffffffff
    @earning_message.message "Earning: #{@shop.baker.money}", 0xffffffff
  end
  
  def window= shop
    @font = Gosu::Font.new(shop.window, 'media/hand.ttf', 25)
    @background = Gosu::Image.new(shop.window, 'media/info_pane.png', true)
    @baker_goal_message = ActionMessage.new @font, @background.width/2, 50
    @earning_message = ActionMessage.new @font, @background.width/2, 80
  end
  
  def draw
    @background.draw(0, 0, ZOrder::MODAL_PANES)
    @baker_goal_message.draw ZOrder::MODAL_PANES
    @earning_message.draw ZOrder::MODAL_PANES
  end
end