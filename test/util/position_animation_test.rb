require File.join(File.dirname(__FILE__), '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'src', 'util', 'position_animation')

class Util::PositionAnimationTest < Test::Unit::TestCase
  context "Animation" do
    setup do
      @initial_x, @initial_y = 20, 20
    end

    context "with one sides animation" do
      setup do
        @callbacks = {}
        @animation = Util::PositionAnimation.new({:x => @initial_x, :y => @initial_y}, {:x => 40, :y => 60}, 20, false, @callbacks, self)
        @animation.start
      end

      context "with no callbacks" do
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

      context "with callback methods" do
        setup do
          @called_25, @called_50, @called_80, @called_99 = [false]*4
          (class << self; self; end).send(:define_method, :on_25) {|x, y| assert(@initial_x + 5  < x); assert(@initial_y + 10 < y); @called_25 = true;}
          (class << self; self; end).send(:define_method, :on_50) {|x, y| assert(@initial_x + 10 < x); assert(@initial_y + 20 < y); @called_50 = true;}
          (class << self; self; end).send(:define_method, :on_80) {|x, y| assert(@initial_x + 16 < x); assert(@initial_y + 32 < y); @called_80 = true;}
          (class << self; self; end).send(:define_method, :on_99) {|x, y| assert_equal(@initial_x + 20, x); assert(@initial_y + 40, y); @called_99 = true;}
          @callbacks[25] = :on_25
          @callbacks[50] = :on_50
          @callbacks[80] = :on_80 
          @callbacks[99] = :on_99 
        end

        should "play equidestent hops for a given x and y range" do
          (0..20).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
          end
          assert @called_25
          assert @called_50
          assert @called_80
          assert @called_99
        end
      end

      context "with callback proc(s)" do
        setup do
          @callbacks[25] = lambda {|x, y| assert(@initial_x + 5  < x); assert(@initial_y + 10 < y); @called_25 = true;}
          @callbacks[50] = lambda {|x, y| assert(@initial_x + 10 < x); assert(@initial_y + 20 < y); @called_50 = true;}
          @callbacks[80] = lambda {|x, y| assert(@initial_x + 16 < x); assert(@initial_y + 32 < y); @called_80 = true;}
          @callbacks[99] = lambda {|x, y| assert_equal(@initial_x + 20, x); assert(@initial_y + 40, y); @called_99 = true;} 
        end

        should "play equidestent hops for a given x and y range" do
          (0..20).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
          end
          assert @called_25
          assert @called_50
          assert @called_80
          assert @called_99
        end
      end
    end

    context "with sub unit hop_length" do
      setup do
        @initial_x, @initial_y = 20, 20
        @final_x, @final_y = 30, 30
        @animation = Util::PositionAnimation.new({:x => @initial_x, :y => @initial_y}, {:x => @final_x, :y => @final_y}, 20)
        @animation.start
      end

      should "work" do
        (0..20).to_a.each do |delta|
          @x_now, @y_now = @animation.hop
          assert_equal(@initial_x + delta.to_f/2, @x_now)
          assert_equal(@initial_y + delta.to_f/2, @y_now)
        end
      end
    end

    context "bi sided animation" do
      setup do
        @final_x, @final_y = 40, 60
        @callbacks = {}
        @animation = Util::PositionAnimation.new({:x => @initial_x, :y => @initial_y}, {:x => @final_x, :y => @final_y}, 40, true, @callbacks, self)
        @animation.start
      end

      context "with no callbacks" do
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

      context "with callback methods" do
        setup do
          @called_25, @called_50, @called_80, @called_99 = [false]*4
          (class << self; self; end).send(:define_method, :on_25) {|x, y| assert(@initial_x + 10 < x); assert(@initial_y + 20 < y); @called_25 = true;}
          (class << self; self; end).send(:define_method, :on_50) {|x, y| assert(@final_x > x); assert(@final_y > y); @called_50 = true;}
          (class << self; self; end).send(:define_method, :on_80) {|x, y| assert(@final_x - 12 > x); assert(@final_y - 24 > y); @called_80 = true;}
          (class << self; self; end).send(:define_method, :on_99) {|x, y| assert_equal(@initial_x, x); assert_equal(@initial_y, y); @called_99 = true;}
          @callbacks[25] = :on_25
          @callbacks[50] = :on_50
          @callbacks[80] = :on_80
          @callbacks[99] = :on_99
        end

        should "play equidestent hops for a given x and y range" do
          (0..40).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
          end
          assert @called_25
          assert @called_50
          assert @called_80
          assert @called_99
        end
      end

      context "with callback proc(s)" do
        setup do
          @called_25, @called_50, @called_80, @called_99 = [false]*4
          @callbacks[25] = lambda {|x, y| assert(@initial_x + 10 < x); assert(@initial_y + 20 < y); @called_25 = true;}
          @callbacks[50] = lambda {|x, y| assert(@final_x > x); assert(@final_y > y); @called_50 = true;}
          @callbacks[80] = lambda {|x, y| assert(@final_x - 12 > x); assert(@final_y - 24 > y); @called_80 = true;}
          @callbacks[99] = lambda {|x, y| assert_equal(@initial_x, x); assert_equal(@initial_y, y); @called_99 = true;} 
        end

        should "play equidestent hops for a given x and y range" do
          (0..40).to_a.each do |delta|
            @x_now, @y_now = @animation.hop
          end
          assert @called_25
          assert @called_50
          assert @called_80
          assert @called_99
        end
      end
    end
  end
end