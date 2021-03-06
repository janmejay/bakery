
class InfoPane
  
  include AliveAsset
  
  def initialize shop
    @shop = shop
  end
  
  def update
    @baker_goal_message.message "Goal: #{@shop.level.required_earning.to_i}", 0xfff3dfbc
    @earning_message.message "Earning: #{@shop.money_drawer.money.to_i}", 0xfff3dfbc
  end
  
  def window= shop
    @font = Gosu::Font.new(shop.window, res('media/hand.ttf'), 25)
    @background = Gosu::Image.new(shop.window, res('media/info_pane.png'), true)
    @level_label = ActionMessage.new @font, @background.width/2, 48
    @overall_holdings = ActionMessage.new @font, @background.width/2, 78
    @this_months_chart = ActionMessage.new @font, @background.width/2, 108
    @baker_goal_message = ActionMessage.new @font, @background.width/2, 134
    @earning_message = ActionMessage.new @font, @background.width/2, 160
    @this_months_chart.message "For this month...", 0xfffcd38d
    lvl_no = @shop.level.level_number
    @level_label.message "Level: #{lvl_no} (#{Date::MONTHNAMES[lvl_no]})", 0xfffcd38d
    @overall_holdings.message "Bank balance: #{@shop.bank_account.money.to_i}", 0xfffcd38d
  end
  
  def draw
    @background.draw(0, 0, ZOrder::MODAL_PANES)
    @level_label.draw ZOrder::MODAL_PANES
    @overall_holdings.draw ZOrder::MODAL_PANES
    @this_months_chart.draw ZOrder::MODAL_PANES
    @baker_goal_message.draw ZOrder::MODAL_PANES
    @earning_message.draw ZOrder::MODAL_PANES
  end
end
