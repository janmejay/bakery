require File.join(File.dirname(__FILE__), 'test_helper')

require File.join(File.dirname(__FILE__), '..', 'src', 'bakery_wizard')
require File.join(File.dirname(__FILE__), '..', 'src', 'serialization_defaulter')

class SerializationDefaulterTest < Test::Unit::TestCase
  context "Serialization defaulting" do
    setup do
      @window = BakeryWizard::BaseWindow.new 10, 10, false
    end
    
    should "work for Window" do
      assert_nil Marshal.load(Marshal.dump(@window))
    end
    
    should "work for Image" do
      img = Gosu::Image.new(@window, "test_media/foo_strip.png", true)
      assert_nil Marshal.load(Marshal.dump(img))
    end
    
    should "work for Font" do
      font = Gosu::Font.new(@window, 'test_media/hand.ttf', 35)
      assert_nil Marshal.load(Marshal.dump(font))
    end
    
    should "work for Sample" do
      sample = Gosu::Sample.new(@window, 'test_media/sound.ogg')
      assert_nil Marshal.load(Marshal.dump(sample))
    end
  end
end