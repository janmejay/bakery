# User: janmejay.singh
# Time: 21 Jun, 2008 7:06:39 PM

require File.join(File.dirname(__FILE__), '..', 'test_helper')

class Util::AnimatorTest < Test::Unit::TestCase
  context "An animation" do

    ANIM_FILE_NAME = File.join(File.dirname(__FILE__), '..', 'test_media', 'foo_strip.png')

    setup do
      @window = Gosu::Window.new(120, 30, false)
      @one_way_anim = Util::Animator.new(@window, ANIM_FILE_NAME, 30, 30, false, 1)
    end

    context "when created" do
      should "have slides loaded" do
        assert_equal 3, @one_way_anim.instance_variable_get('@slides').length
      end

      should "have set @play_both_ways to false(for one way anim)" do
        assert !@one_way_anim.instance_variable_get('@play_both_ways')
      end

      should "have @animated_sequence built" do
        assert_equal @one_way_anim.instance_variable_get('@slides'), @one_way_anim.instance_variable_get('@animated_sequence')
      end
    end

    should "not start the animation on its own" do
      @one_way_anim.expects(:update_running_status).never
      @one_way_anim.expects(:update_chunk_state).never
      @one_way_anim.instance_variable_get('@slides').expects(:[]).with(0).returns(:foo)
      assert_equal :foo, @one_way_anim.slide
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
      end
    end
    
    context "callback handler" do
      setup do
        @callback_anim = Util::Animator.new(@window, ANIM_FILE_NAME, 30, 30) do
          callback_method
        end
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
        @two_way_anim = Util::Animator.new(@window, ANIM_FILE_NAME, 30, 30, true, 1)
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
        @custom_slice_width_anim = Util::Animator.new(@window, ANIM_FILE_NAME, 30, 30, false, ANIM_SLICE_WIDTH)
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
            @custom_width_slice_bysided_anim = Util::Animator.new(@window, ANIM_FILE_NAME, 30, 30, true, ANIM_SLICE_WIDTH)
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
        @anim_with_infinite_length = Util::Animator.new(@window, ANIM_FILE_NAME, 30, 30, false, 1, true)
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

        should "run infinitely" do
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