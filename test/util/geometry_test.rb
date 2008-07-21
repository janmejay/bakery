require File.join(File.dirname(__FILE__), '..', 'test_helper')

require File.join(File.dirname(__FILE__), '..', '..', 'src', 'util', 'geometry')

class GeometryTest < Test::Unit::TestCase
  include Util::Geometry
  context "Geometry" do
    context "finding offset coordinates" do
      setup do
        @x = 40
        @y = 80
        @angle = 0
      end
      
      context "with top-left vertex normalization" do
        setup do
          @width, @height = 20, 30
        end
        
        should "work for y-displacement" do
          x, y = offset(0, offset = 10, @width, @height)
          assert_equal(@x - @width/2, x)
          assert_equal(@y - offset - @height/2, y)
        end

        should "work for x-displacement" do
          x, y = offset(90, offset = 10, @width, @height)
          assert_equal(@x + offset - @width/2, x)
          assert_equal(@y - @height/2, y)
        end
        
        context "for negetive coordinates" do
          should "work for y-displacement" do
            x, y = offset(180, offset = 10, @width, @height)
            assert_equal(@x - @width/2, x)
            assert_equal(@y + offset - @height/2, y)
          end

          should "work for x-displacement" do
            x, y = offset(270, offset = 10, @width, @height)
            assert_equal(@x - offset - @width/2, x)
            assert_equal(@y - @height/2, y)
          end
        end
      end
      
      context "with no angular offset" do
        should "work for y-displacement" do
          x, y = offset(0, offset = 10)
          assert_equal(@x, x)
          assert_equal(@y - offset, y)
        end

        should "work for x-displacement" do
          x, y = offset(90, offset = 10)
          assert_equal(@x + offset, x)
          assert_equal(@y, y)
        end
        
        context "with negetive angles" do
          should "work for y-displacement" do
            x, y = offset(180, offset = 10)
            assert_equal(@x, x)
            assert_equal(@y + offset, y)
          end

          should "work for x-displacement" do
            x, y = offset(270, offset = 10)
            assert_equal(@x - offset, x)
            assert_equal(@y, y)
          end
        end
      end
      
      context "with angular offset" do
        setup do
          @angle = 45
        end
        
        should "work for y-displacement" do
          x, y = offset(315, offset = 10)
          assert_equal(@x, x)
          assert_equal(@y - offset, y)
        end

        should "work for x-displacement" do
          x, y = offset(45, offset = 10)
          assert_equal(@x + offset, x)
          assert_equal(@y, y)
        end
      end
    end
  end
end