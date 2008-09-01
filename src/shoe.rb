class Shoe
  include NoUiAsset
  
  def initialize context_shoe_data
    @shoe_data = context_shoe_data
  end
  
  def window= shop
    shop.baker.wear_shoes self
  end
  
  def speed
    @shoe_data[:speed]
  end
  
  def walking_anim_slice_width
    @shoe_data[:walking_anim_slice_width]
  end
end