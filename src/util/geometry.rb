module Util::Geometry
  def offset(angle, radius, normalize_for_width = 0, normalize_for_heigth = 0)
    angle_in_rads = (@angle.to_f + angle.to_f)*Math::PI/180
    return x_offset(radius, angle_in_rads) - normalize_for_width.to_f/2, y_offset(radius, angle_in_rads) - normalize_for_heigth.to_f/2
  end
  
  private
  def x_offset radius, angle_in_rads
    @x + Math::sin(angle_in_rads)*radius.to_f
  end
  
  def y_offset radius, angle_in_rads
    @y - Math::cos(angle_in_rads)*radius.to_f
  end
end