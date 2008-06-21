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
      should "have @running set to false" do
        assert !@one_way_anim.instance_variable_get('@running')
      end

      should "have slides loaded" do
        assert_equal 3, @one_way_anim.instance_variable_get('@slides').length
      end

      should "have run mode forward" do
        assert @one_way_anim.instance_variable_get('@forward')
      end

      should "have set @play_both_ways to false(for one way anim)" do
        assert !@one_way_anim.instance_variable_get('@play_both_ways')
      end

      should "have @chunks_finished and @slices_done_for_this_chunk set correctly" do
        assert_equal 0, @one_way_anim.instance_variable_get('@chunks_finished')
        assert_equal 0, @one_way_anim.instance_variable_get('@slices_done_for_this_chunk')
      end
    end

    should "not start the animation on its own" do
      @one_way_anim.expects(:update_running_status).never
      @one_way_anim.expects(:update_chunk_state).never
      @one_way_anim.instance_variable_get('@slides').expects(:[]).with(0).returns(:foo)
      assert_equal :foo, @one_way_anim.slide
    end

    should "set @running, @chunks_finished and @forward when started" do
      @one_way_anim.start
      assert @one_way_anim.instance_variable_get('@running')
      assert_equal 0, @one_way_anim.instance_variable_get('@chunks_finished') 
      assert @one_way_anim.instance_variable_get('@forward') 
    end

    context "when played one way" do

      should "state cycling should not happen" do
        assert !@one_way_anim.instance_variable_get('@running')
        slides = @one_way_anim.instance_variable_get('@slides')
        assert_equal slides[0], @one_way_anim.slide
        assert_equal slides[0], @one_way_anim.slide
        assert_equal slides[0], @one_way_anim.slide
        assert_equal slides[0], @one_way_anim.slide
      end

      context "while running" do
        setup do
          @one_way_anim.start
        end

        should "cycle through all the slides" do
          slides = @one_way_anim.instance_variable_get('@slides')
          assert @one_way_anim.instance_variable_get('@running')
          assert_equal slides[0], @one_way_anim.slide
          assert @one_way_anim.instance_variable_get('@running')
          assert_equal slides[1], @one_way_anim.slide
          assert @one_way_anim.instance_variable_get('@running')
          assert_equal slides[2], @one_way_anim.slide
          assert !@one_way_anim.instance_variable_get('@running')
          assert_equal slides[0], @one_way_anim.slide
          assert !@one_way_anim.instance_variable_get('@running')
          assert_equal slides[0], @one_way_anim.slide
        end
      end
    end

    context "when played both ways" do
      setup do
        @two_way_anim = Util::Animator.new(@window, ANIM_FILE_NAME, 30, 30, true, 1)
      end

      should "state cycling should not happen" do
        assert !@one_way_anim.instance_variable_get('@running')
        slides = @one_way_anim.instance_variable_get('@slides')
        assert_equal slides[0], @one_way_anim.slide
        assert_equal slides[0], @one_way_anim.slide
        assert_equal slides[0], @one_way_anim.slide
        assert_equal slides[0], @one_way_anim.slide
      end

#      context "while running" do
#        setup do
#          @one_way_anim.start
#        end
#
#        should "cycle through all the slides" do
#          slides = @one_way_anim.instance_variable_get('@slides')
#          assert @one_way_anim.instance_variable_get('@running')
#          assert_equal slides[0], @one_way_anim.slide
#          assert @one_way_anim.instance_variable_get('@running')
#          assert_equal slides[1], @one_way_anim.slide
#          assert @one_way_anim.instance_variable_get('@running')
#          assert_equal slides[2], @one_way_anim.slide
#          assert !@one_way_anim.instance_variable_get('@running')
#          assert_equal slides[0], @one_way_anim.slide
#          assert !@one_way_anim.instance_variable_get('@running')
#          assert_equal slides[0], @one_way_anim.slide
#        end
#      end
    end

    context "when played with custom time slice width" do
      setup do
        @custom_slice_width_anim = Util::Animator.new(@window, ANIM_FILE_NAME, 30, 30, false, 10)
      end
    end

  end
end