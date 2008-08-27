class Warehouse < BakeryWizard::Window
  
  class Item
    
    THMB_V_PAD = (108 - 80)/2
    THMB_H_PAD = 10
    
    DESC_H_PAD = 100
    DESC_V_PAD_1 = 50
    DESC_V_PAD_2 = 70
    
    TITLE_H_PAD = DESC_H_PAD
    TITLE_V_PAD = 16
    
    @@count = 0
    
    def initialize warehouse, item_data, having = false
      @item_data = item_data
      @thumb_img = Gosu::Image.new(warehouse.window, @item_data[:thumbnail], false)
      @bg_img = Gosu::Image.new(warehouse.window, having ? 'media/item_already_bought.png' : 'media/item_to_be_bought.png', false)
      @desc_font = Gosu::Font.new(warehouse.window, 'media/hand.ttf', 25)
      @main_font = Gosu::Font.new(warehouse.window, 'media/hand.ttf', 35)
      @x, @y = self.class.get_coordinates
      @@count += 1
      @descriptions = @item_data[:description].split(/#/)
    end
    
    def draw
      @bg_img.draw(@x, @y, 0)
      @thumb_img.draw(@x + THMB_H_PAD, @y + THMB_V_PAD, 0)
      @main_font.draw(@item_data[:name], @x + TITLE_H_PAD, @y + TITLE_V_PAD, 0, 1.0, 1.0, 0xff000000)
      @desc_font.draw(@descriptions.first, DESC_H_PAD, @y + DESC_V_PAD_1, 0, 1.0, 1.0, 0xff000000)
      @desc_font.draw(@descriptions.last, DESC_H_PAD, @y + DESC_V_PAD_2, 0, 1.0, 1.0, 0xff000000)
    end
    
    private
    def self.get_coordinates
      return (@@count/6)*512, @@count*108
    end
  end
  
  def initialize context
    @context = context
    @cursor = Cursor.new
    @warehouse_data = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', 'warehouse-stock.yml'))
  end
  
  def window= window
    @window = window
    @cursor.window = self
    @items = []
    @warehouse_data.each do |item_key, item_data|
      @items << Item.new(self, item_data)
    end
  end
  
  def update
    
  end
  
  def draw
    @cursor.draw
    @items.each {|item| item.draw }
  end
end