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
        self.assertEquals(self.action._Action__propagatable, True)
        self.assertEquals(self.action._Action__consumers, [])

class SampleSubscriber(actions.Subscriber):
    def handle(self, action):
        pass

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
        self.subscriber = SampleSubscriber()
        self.action = actions.Action(actions.LEFT_CLICK, 10, 20)

    def test_should_add_itself_to_the_consumers_list_on_consuming_action(self):
        self.subscriber.consume(self.action)
        self.assertTrue(self.subscriber in self.action._Action__consumers)

class All(unittest.TestSuite):
    def __init__(self):
        self.add(ActionTest)
        self.add(SubscriberTest)
        self.add(PublisherTest)

if __name__ == '__main__':
    unittest.main()
