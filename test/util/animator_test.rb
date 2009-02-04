# User: janmejay.singh
# Time: 21 Jun, 2008 7:06:39 PM

require File.join(File.dirname(__FILE__), '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'src', 'util', 'animator')

class Util::AnimatorTest < Test::Unit::TestCase
  context "An animation" do

    ANIM_FILE_NAME = File.join(File.dirname(__FILE__), '..', 'test_media', 'foo_strip.png')

    setup do
      @window = Gosu::Window.new(120, 30, false)
      @one_way_anim = Util::Animator.new(ANIM_FILE_NAME, 30, 30, {:callback_map => @callback_map = {50 => :foo}, :callback_receiver => @callback_receiver = Object.new})
      @callback_receiver.stubs(:foo)
      @one_way_anim.window = @window
    end

    context "when created" do
      should "have slides loaded" do
        assert_equal 3, @one_way_anim.instance_variable_get('@slides').length
      end

      should "not be running" do
        assert_nil @one_way_anim.running?
      end

      should "have set @play_both_ways to false(for one way anim)" do
        assert !@one_way_anim.instance_variable_get('@play_both_ways')
      end

      should "have @animated_sequence built" do
        assert_equal @one_way_anim.instance_variable_get('@slides'), @one_way_anim.instance_variable_get('@animated_sequence')
      end

      should "pick up sample(sound)" do
        @one_way_anim.attach_sound(sample = Object.new)
        assert_equal sample, @one_way_anim.instance_variable_get('@sample')
      end

      should "pick up callback hooks" do
        assert_equal @callback_map, @one_way_anim.instance_variable_get('@callback_map')
      end
    end

    should "not start the animation on its own" do
      @one_way_anim.expects(:update_running_status).never
      @one_way_anim.expects(:update_chunk_state).never
      @one_way_anim.instance_variable_get('@slides').expects(:[]).with(0).returns(:foo)
      assert_equal :foo, @one_way_anim.slide
    end

    should "reset the progress on start" do
      @one_way_anim.instance_variable_set('@progress', 20)
      @one_way_anim.start
      assert_equal 0, @one_way_anim.instance_variable_get('@progress')
    end

    context "when played one way" do
      setup do
        @slides = @one_way_anim.instance_variable_get('@slides')
      end

      should "not cycle unless started" do
        assert !@one_way_anim.instance_variable_get('@running')
        assert_equal @slides[0], @one_way_anim.slide
        assert_equal @slides[0], @one_way_anim.slide
        assert_equal @slides[0], @one_way_anim.slide
        assert_equal @slides[0], @one_way_anim.slide
      end

      context "while running" do
        setup do
          @one_way_anim.start
        end

        should "be running" do
          assert @one_way_anim.running?
        end

        should "not be running post stop" do
          @one_way_anim.stop
          assert !@one_way_anim.running?
        end

        should "not bomb when no callback_receiver given even if callback_map is there" do
          @one_way_anim.instance_variable_set('@callback_receiver', nil)
          assert_nothing_raised do
            @one_way_anim.slide
            @one_way_anim.slide
            @one_way_anim.slide
          end
        end

        should "invoke callbacks if callback_receiver is given" do
          @one_way_anim.slide
          @callback_receiver.expects(:foo)
          @one_way_anim.slide
          @callback_receiver.expects(:foo).never
          @one_way_anim.slide
        end

        should "cycle through all the slides" do
          assert_equal @slides[0], @one_way_anim.slide
          assert_equal @slides[1], @one_way_anim.slide
          assert_equal @slides[2], @one_way_anim.slide
          assert_equal @slides[0], @one_way_anim.slide
          assert_equal @slides[0], @one_way_anim.slide
        end

        should "be able to stop animation" do
          assert_equal @slides[0], @one_way_anim.slide
          assert_equal @slides[1], @one_way_anim.slide
          @one_way_anim.stop
          assert_equal @slides[0], @one_way_anim.slide
          assert_equal @slides[0], @one_way_anim.slide
        end

        context "when sound attached" do
          setup do
            @one_way_anim.attach_sound(@sample = Object.new)
          end
          
          should "play sample when running" do
            @sample.expects(:playing?).returns(false)
            @sample.expects(:play)
            @one_way_anim.slide
            @sample.expects(:playing?).returns(true)
            @one_way_anim.slide
            @sample.expects(:playing?).returns(false)
            @sample.expects(:play)
            @one_way_anim.slide
          end

          should "not play sample when not running" do
            @sample.expects(:stop).times(3)
            @one_way_anim.stop
            @sample.expects(:playing?).never
            @sample.expects(:play).never
            @one_way_anim.slide
            @one_way_anim.slide
          end
        end
      end
    end
    
    context "callback proc handler" do
      setup do
        @callback_anim = Util::Animator.new(ANIM_FILE_NAME, 30, 30) do
          callback_method
        end
        @callback_anim.window = @window
        @callback_anim.start
      end
      
      context "when running the animation" do
        setup do
          @callback_anim.slide
          @callback_anim.slide
        end

        should "not execute the callback before the end" do
          self.expects(:callback_method).never
        end
        
        context "@ the end of anim" do
          should "execute the callback" do
            self.expects(:callback_method).once
            @callback_anim.slide
          end
        end
      end
    end
    
    context "callback :method handler" do
      setup do
        @callback_anim = Util::Animator.new(ANIM_FILE_NAME, 30, 30, :call_on_completion => :callback_method, :callback_receiver => self)
        @callback_anim.window = @window
        @callback_anim.start
      end
      
      context "when running the animation" do
        setup do
          @callback_anim.slide
          @callback_anim.slide
        end

        should "not execute the callback before the end" do
          self.expects(:callback_method).never
        end
        
        context "@ the end of anim" do
          should "execute the callback" do
            self.expects(:callback_method).once
            @callback_anim.slide
          end
        end
      end
    end

    context "when played both ways" do
      setup do
        @two_way_anim = Util::Animator.new(ANIM_FILE_NAME, 30, 30, :play_both_ways => true)
        @two_way_anim.window = @window
        @slides = @two_way_anim.instance_variable_get('@slides')
      end

      should "not cycle unless started" do
        assert_equal @slides[0], @two_way_anim.slide
        assert_equal @slides[0], @two_way_anim.slide
        assert_equal @slides[0], @two_way_anim.slide
        assert_equal @slides[0], @two_way_anim.slide
      end

      context "while running" do
        setup do
          @two_way_anim.start
        end

        should "cycle through all the slides" do
          assert_equal @slides[0], @two_way_anim.slide
          assert_equal @slides[1], @two_way_anim.slide
          assert_equal @slides[2], @two_way_anim.slide
          assert_equal @slides[1], @two_way_anim.slide
          assert_equal @slides[0], @two_way_anim.slide
          assert_equal @slides[0], @two_way_anim.slide
          assert_equal @slides[0], @two_way_anim.slide
        end

        should "be able to stop animation" do
          assert_equal @slides[0], @two_way_anim.slide
          assert_equal @slides[1], @two_way_anim.slide
          @two_way_anim.stop
          assert_equal @slides[0], @two_way_anim.slide
          assert_equal @slides[0], @two_way_anim.slide
        end
      end
    end

    context "when played with custom time slice width" do
      ANIM_SLICE_WIDTH = 10

      setup do
        @custom_slice_width_anim = Util::Animator.new(ANIM_FILE_NAME, 30, 30, :chunk_slice_width => ANIM_SLICE_WIDTH)
        @custom_slice_width_anim.window = @window
        @slides = @custom_slice_width_anim.instance_variable_get('@slides')
      end

      should "not cycle unless started" do
        assert_equal @slides[0], @custom_slice_width_anim.slide
        assert_equal @slides[0], @custom_slice_width_anim.slide
        assert_equal @slides[0], @custom_slice_width_anim.slide
        assert_equal @slides[0], @custom_slice_width_anim.slide
      end

      context "while playing the anim," do

        setup do
          @custom_slice_width_anim.start
        end

        should "return same slide #{ANIM_SLICE_WIDTH} times" do
          ANIM_SLICE_WIDTH.times { assert_equal @slides[0], @custom_slice_width_anim.slide }
          ANIM_SLICE_WIDTH.times { assert_equal @slides[1], @custom_slice_width_anim.slide }
          ANIM_SLICE_WIDTH.times { assert_equal @slides[2], @custom_slice_width_anim.slide }
          ANIM_SLICE_WIDTH*2.times { assert_equal @slides[0], @custom_slice_width_anim.slide }
        end

        context "both sides," do
          setup do
            @custom_width_slice_bysided_anim = Util::Animator.new(ANIM_FILE_NAME, 30, 30, :play_both_ways => true, :chunk_slice_width => ANIM_SLICE_WIDTH)
            @custom_width_slice_bysided_anim.window = @window
            @custom_width_slice_bysided_anim.start
            @slides = @custom_width_slice_bysided_anim.instance_variable_get('@slides')
          end

          should "return same slide #{ANIM_SLICE_WIDTH} times" do
            ANIM_SLICE_WIDTH.times { assert_equal @slides[0], @custom_width_slice_bysided_anim.slide }
            ANIM_SLICE_WIDTH.times { assert_equal @slides[1], @custom_width_slice_bysided_anim.slide }
            ANIM_SLICE_WIDTH.times { assert_equal @slides[2], @custom_width_slice_bysided_anim.slide }
            ANIM_SLICE_WIDTH.times { assert_equal @slides[1], @custom_width_slice_bysided_anim.slide }
            ANIM_SLICE_WIDTH*2.times { assert_equal @slides[0], @custom_width_slice_bysided_anim.slide }
          end

          should "be able to stop animation" do
            ANIM_SLICE_WIDTH.times { assert_equal @slides[0], @custom_width_slice_bysided_anim.slide }
            assert_equal @slides[1], @custom_width_slice_bysided_anim.slide
            @custom_width_slice_bysided_anim.stop
            ANIM_SLICE_WIDTH*2.times { assert_equal @slides[0], @custom_width_slice_bysided_anim.slide }
          end
        end
      end
    end

    context "marked for infinite running" do
      setup do
        @anim_with_infinite_length = Util::Animator.new(ANIM_FILE_NAME, 30, 30, :run_indefinitly => true, :callback_map => {10 => :foo, 40 => :bar}, :callback_receiver => @callback_receiver)
        @anim_with_infinite_length.window = @window
        @slides = @anim_with_infinite_length.instance_variable_get('@slides')
      end

      should "not cycle unless started" do
        assert_equal @slides[0], @anim_with_infinite_length.slide
        assert_equal @slides[0], @anim_with_infinite_length.slide
        assert_equal @slides[0], @anim_with_infinite_length.slide
        assert_equal @slides[0], @anim_with_infinite_length.slide
      end

      context "when running" do
        setup do
          @anim_with_infinite_length.start
        end

        should "invoke the callback @ the correct time" do
          3.times do
            @callback_receiver.expects(:foo)
            @anim_with_infinite_length.slide
            @callback_receiver.expects(:foo).never
            @callback_receiver.expects(:bar)
            @anim_with_infinite_length.slide
            @callback_receiver.expects(:bar).never
            @anim_with_infinite_length.slide
          end
        end

        should "run infinitely" do
          @callback_receiver.stubs(:bar)
          assert_equal @slides[0], @anim_with_infinite_length.slide
          assert_equal @slides[1], @anim_with_infinite_length.slide
          assert_equal @slides[2], @anim_with_infinite_length.slide
          assert_equal @slides[0], @anim_with_infinite_length.slide
          assert_equal @slides[1], @anim_with_infinite_length.slide
          assert_equal @slides[2], @anim_with_infinite_length.slide
          assert_equal @slides[0], @anim_with_infinite_length.slide
        end

        should "be able to stop" do
          assert_equal @slides[0], @anim_with_infinite_length.slide
          assert_equal @slides[1], @anim_with_infinite_length.slide
          @anim_with_infinite_length.stop
          assert_equal @slides[0], @anim_with_infinite_length.slide
          assert_equal @slides[0], @anim_with_infinite_length.slide
          assert_equal @slides[0], @anim_with_infinite_length.slide
        end
      end
    end
  end
end
