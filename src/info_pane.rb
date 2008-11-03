
class InfoPane
  
  include AliveAsset
  
  def initialize shop
    @shop = shop
  end
  
  def update
    @expectation = @shop.level.required_earnings
    @achived = @shop.baker.money
  end
  
  def window= shop
    @font = Gosu::Font.new(shop.window, 'media/hand.ttf', 25)
    @background = Gosu::Image.new(shop.window, 'media/info_pane.png', true)
  end
  
  def draw
    @background.draw(0, 0, ZOrder::MODAL_PANES)
    @font.draw("Baker's Goal: #{@expectation}", 20, 40, ZOrder::MODAL_PANES, 1.0, 1.0, 0xffffffff)
    @font.draw("Earning: #{@achived}", 20, 80, ZOrder::MODAL_PANES, 1.0, 1.0, 0xffffffff)
  end
end