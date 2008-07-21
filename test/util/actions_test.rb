require File.join(File.dirname(__FILE__), '..', 'test_helper')

require File.join(File.dirname(__FILE__), '..', '..', 'src', 'util', 'actions')

class ActionsTest < Test::Unit::TestCase
  
  context "A publisher" do
    setup do
      @publisher = Class.new do
        include Actions::Publisher
      end.new
      @event = Actions::Event.new(:left_click, 10, 20)
      subscriber_class = Class.new do
        include Actions::Subscriber
        def initialize zindex
          @zindex = zindex
        end
        protected
        def zindex
          @zindex
        end
      end
      @subscriber_1 = subscriber_class.new 1
      @subscriber_2 = subscriber_class.new 2
      @subscriber_3 = subscriber_class.new 3
      @subscriber_4 = subscriber_class.new 4
      @subscriber_5 = subscriber_class.new 5
    end

    should "post all subscribers about a published event" do
      @publisher.register(@subscriber_3, @subscriber_2, @subscriber_1)
      [@subscriber_1, @subscriber_2, @subscriber_3].each { |subscriber| subscriber.expects(:consume).with(@event)}
      @publisher.publish(@event)
    end
    
    should "not post to unregistered subscribers" do
      @publisher.register(@subscriber_3, @subscriber_2, @subscriber_1)
      @publisher.unregister(@subscriber_1, @subscriber_2)
      @subscriber_3.expects(:consume).with(@event)
      [@subscriber_1, @subscriber_2].each { |subscriber| subscriber.expects(:consume).never}
      @publisher.publish(@event)
    end
    
    should "keep subsribers sorted on zindex" do
      @publisher.register(@subscriber_4, @subscriber_2, @subscriber_1)
      @publisher.register(@subscriber_5, @subscriber_3)
      ordered_subscribers = @publisher.instance_variable_get('@subscribers')
      assert_equal([@subscriber_5, @subscriber_4, @subscriber_3, @subscriber_2, @subscriber_1], ordered_subscribers)
    end
  end
  
  context "A subscriber" do
    setup do
      @publisher = Class.new do
        include Actions::Publisher
      end.new
      @subscriber = Class.new do
        include Actions::Subscriber
      end.new
      @event = Actions::Event.new(:left_click, 10, 20)
    end
    
    context "by default" do
      should "not consume anything" do
        @subscriber.expects(:handle).never
        @subscriber.consume(@event)
      end
    end
    
    context "when allowing consumption" do
      setup do
        class << @subscriber
          def can_consume?(event)
            true
          end
        end
      end
      
      should "allow event if can consume" do
        @subscriber.expects(:handle).with(@event)
        @subscriber.consume(@event)
      end

      should "add consuming event to consumers of the event" do
        @subscriber.consume(@event)
        assert_equal([@subscriber], @event.consumers)
      end
      
      context "propagation" do
        context "by default" do
          
          setup do
            @subscriber.consume(@event)
          end
          
          should "be false" do
            assert(!@event.propagatable)
          end
        end
        
        context "when propagation allowed" do
          setup do
            class << @subscriber
              def allow_propagation?(event)
                true
              end
            end
          end
          
          should "propagate" do
            @subscriber.consume(@event)
            assert(@event.propagatable)
          end
        end
      end
    end
  end
  
  context "An active rectangle subscriber" do
    
    setup do
      @subscriber = Class.new do
        include Actions::ActiveRectangleSubscriber
        
        protected
        def active_x
          return 10, 50
        end
        
        def active_y
          return 20, 30
        end
      end.new
      @allowed_event = Actions::Event.new(:left_click, 15, 23)
      @disallowed_Y_event = Actions::Event.new(:left_click, 15, 43)
      @disallowed_X_event = Actions::Event.new(:left_click, 5, 27)
    end
    
    should "allow consumption of a propagatable event in active area" do
      assert @subscriber.send(:can_consume?, @allowed_event)
    end
    
    context "when receving event from inactive area" do
      
      should "not allow consumption for x out of range" do
        assert !@subscriber.send(:can_consume?, @disallowed_X_event)
      end
      
      should "not allow consumption for y out of range" do
        assert !@subscriber.send(:can_consume?, @disallowed_Y_event)
      end
    end
  end
end