import unittest
import env
import sys
from util import actions
import mox

class ActionTest(unittest.TestCase):
    def setUp(self):
        self.action = actions.Action(actions.LEFT_CLICK, 10, 20)
    
    def test_starts_with_correct_state(self):
        self.assertEquals(self.action._Action__macro, actions.LEFT_CLICK)
        self.assertEquals(self.action._Action__x, 10)
        self.assertEquals(self.action._Action__y, 20)
        self.assertEquals(self.action.propagatable, True)
        self.assertEquals(self.action._Action__consumers, [])

class SampleSubscriber(actions.Subscriber):
    def __init__(self, zindex):
        self.__zindex = zindex
    
    def handle(self, action):
        pass

    def can_consume(self, action):
        return True

    def zindex(self):
        return self.__zindex
        

class PublisherTest(unittest.TestCase):
    def setUp(self):
        self.publisher = actions.Publisher()
        self.mock_factory = mox.Mox()
        self.subscriber = actions.Subscriber()
        self.mock_factory.StubOutWithMock(self.subscriber, "consume")
        self.action = actions.Action(actions.LEFT_CLICK, 10, 20);

    def test_registered_subscriber_gets_messages(self):
        self.subscriber.consume(self.action)
        self.publisher.register(self.subscriber)
        self.mock_factory.ReplayAll()
        self.publisher.publish(self.action)
        self.mock_factory.VerifyAll()

    def test_same_subscriber_registered_twice_should_not_be_made_to_consume_action_twice(self):
        self.subscriber.consume(self.action)
        self.publisher.register(self.subscriber)
        self.publisher.register(self.subscriber)
        self.mock_factory.ReplayAll()
        self.publisher.publish(self.action)
        self.mock_factory.VerifyAll()

    def test_should_be_able_to_add_multiple_subscribers_at_a_time(self):
        subscriber_2 = actions.Subscriber()
        self.mock_factory.StubOutWithMock(subscriber_2, "consume")
        self.subscriber.consume(self.action)
        subscriber_2.consume(self.action)
        self.publisher.register(self.subscriber, subscriber_2)
        self.mock_factory.ReplayAll()
        self.publisher.publish(self.action)
        self.mock_factory.VerifyAll()

class SubscriberTest(unittest.TestCase):
    def setUp(self):
        self.subscriber = SampleSubscriber(10)
        self.action = actions.Action(actions.LEFT_CLICK, 10, 20)
        self.mock_factory = mox.Mox()

    def test_should_add_itself_to_the_consumers_list_on_consuming_action(self):
        self.subscriber.consume(self.action)
        self.assertTrue(self.subscriber in self.action._Action__consumers)

    def test_should_set_action_propagability(self):
        action_2 = actions.Action(actions.RIGHT_CLICK, 30, 40)
        self.mock_factory.StubOutWithMock(self.subscriber, "allow_propagation")
        self.subscriber.allow_propagation(self.action).AndReturn(False)
        self.subscriber.allow_propagation(action_2).AndReturn(True)
        self.mock_factory.ReplayAll()
        self.subscriber.consume(self.action)
        self.assertFalse(self.action.propagatable)
        self.subscriber.consume(action_2)
        self.assertTrue(action_2.propagatable)

    def test_can_consume_returns_false_and_allow_propagation_returns_true_to_start_with(self):
        subscriber = actions.Subscriber()
        self.assertFalse(subscriber.can_consume(self.action), False)
        self.assertTrue(subscriber.allow_propagation(self.action), True)

    def test_should_implement__cmp__based_on_zindex(self):
        lower_subscriber = SampleSubscriber(10)
        upper_subscriber = SampleSubscriber(15)
        top_subscriber = SampleSubscriber(20)
        array = [upper_subscriber, lower_subscriber, top_subscriber]
        array.sort()
        self.assertEquals(array, [top_subscriber, upper_subscriber, lower_subscriber])

    def test_should_consider_nothing_but_same_instance_equal(self):
        subscriber = SampleSubscriber(10)
        self.assertNotEqual(self.subscriber, subscriber)

class All(unittest.TestSuite):
    def __init__(self):
        self.add(ActionTest)
        self.add(SubscriberTest)
        self.add(PublisherTest)

if __name__ == '__main__':
    unittest.main()
