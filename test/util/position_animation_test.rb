require File.join(File.dirname(__FILE__), '..', 'test_helper')

class Util::PositionAnimationTest < Test::Unit::TestCase
  context "Animation" do
    setup do
      @initial_x, @initial_y = 20, 20
    end
    
    context "with one sides animation" do
      setup do
        @callbacks = {25 => lambda {assert_equal(@initial_x + 5,@x_now); assert_equal(@initial_y + 10, @y_now);},
                     50 => lambda {assert_equal(@initial_x + 10,@x_now); assert_equal(@initial_y + 20, @y_now);},
                     80 => lambda {assert_equal(@initial_x + 16,@x_now); assert_equal(@initial_y + 32, @y_now);},
                     99 => lambda {assert_equal(@initial_x + 20,@x_now); assert_equal(@initial_y + 40, @y_now);}}
        @animation = Util::PositionAnimation.new({:x => @initial_x, :y => @initial_y}, {:x => 40, :y => 60}, 20, false, @callbacks)
        @animation.reset
      end
      
      context "with no callbacks" do
        setup do
          @callbacks.reject! {true}
        end

        should "play equidestent hops for a given x and y range" do
          (0..20).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
            assert_equal(@initial_x + delta, @x_now)
            assert_equal(@initial_y + delta*2, @y_now)
          end
        end

        should "remain @ final point once reached" do
          (20).times do |delta|
            @animation.hop
          end
          3.times do
            @x_now, @y_now = @animation.hop
            assert_equal(40, @x_now)
            assert_equal(60, @y_now)
          end
        end
      end

      context "with callback" do
        should "play equidestent hops for a given x and y range" do
          (0..20).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
          end
        end
      end
    end
    
    context "bi sided animation" do
      setup do
        @final_x, @final_y = 40, 60
        @callbacks = {25 => lambda {assert_equal(@initial_x + 10,@x_now); assert_equal(@initial_y + 20, @y_now);},
                     50 => lambda {assert_equal(@final_x,@x_now); assert_equal(@final_y, @y_now);},
                     80 => lambda {assert_equal(@final_x - 12,@x_now); assert_equal(@final_y - 24, @y_now);},
                     99 => lambda {assert_equal(@initial_x,@x_now); assert_equal(@initial_y, @y_now);}}
        @animation = Util::PositionAnimation.new({:x => @initial_x, :y => @initial_y}, {:x => @final_x, :y => @final_y}, 40, true, @callbacks)
        @animation.reset
      end
      
      context "with no callbacks" do
        setup do
          @callbacks.reject! {true}
        end

        should "play equidestent hops for a given x and y range" do
          (0..20).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
            assert_equal(@initial_x + delta, @x_now)
            assert_equal(@initial_y + delta*2, @y_now)
          end
          (1..20).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
            assert_equal(@final_x - delta, @x_now)
            assert_equal(@final_y - delta*2, @y_now)
          end
        end

        should "remain @ final point once reached" do
          (40).times do |delta|
            @animation.hop
          end
          5.times do
            @x_now, @y_now = @animation.hop
            assert_equal(@initial_x, @x_now)
            assert_equal(@initial_y, @y_now)
          end
        end
      end

      context "with callback" do
        should "play equidestent hops for a given x and y range" do
          (0..40).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
          end
        end
      end
    end
  end
end