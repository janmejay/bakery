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

    def test_defaults_x_y_to_0(self):
        default_x_y_action = actions.Action(actions.LEFT_CLICK)
        self.assertEquals(default_x_y_action.x(), 0)
        self.assertEquals(default_x_y_action.y(), 0)

    def test_click_and_key_actions_are_mutually_exclusive(self):
        self.assertTrue(actions.Action(actions.LEFT_CLICK).is_click())
        self.assertFalse(actions.Action(actions.LEFT_CLICK).is_key())
        self.assertTrue(actions.Action(actions.KEY).is_key())
        self.assertFalse(actions.Action(actions.KEY).is_click())

    def test_left_and_right_click_are_clicks(self):
        self.assertTrue(actions.Action(actions.LEFT_CLICK).is_click())
        self.assertTrue(actions.Action(actions.RIGHT_CLICK).is_click())

    def test_stores_an_optional_object_defaulted_to_none(self):
        self.assertEqual(self.action.get_obj(), None)
        action_obj = object()
        action = actions.Action(actions.KEY, obj = action_obj)
        self.assertEqual(action.get_obj(), action_obj)
        
class SampleSubscriber(actions.Subscriber):
    def __init__(self, zindex):
        self.__zindex = zindex
    
    def handle(self, action):
        pass

    def can_consume(self, action):
        return True

    def zindex(self):
        return self.__zindex
        
class NonPropagatingSampleSubscriber(SampleSubscriber):
    def allow_propagation(self, action):
        return False

    def can_consume(self, action):
        return action.propagatable

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

    def test_unregistered_subscriber_does_not_get_messages(self):
        self.publisher.register(self.subscriber)
        self.publisher.unregister(self.subscriber)
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

    def test_offers_action_for_consumption_in_order_of_subscriber_z_index(self):
        subscriber_1 = NonPropagatingSampleSubscriber(10)
        subscriber_2 = NonPropagatingSampleSubscriber(20)
        subscriber_3 = NonPropagatingSampleSubscriber(30)
        self.publisher.register(subscriber_2, subscriber_1, subscriber_3)
        self.mock_factory.StubOutWithMock(subscriber_1, 'handle')
        self.mock_factory.StubOutWithMock(subscriber_2, 'handle')
        self.mock_factory.StubOutWithMock(subscriber_3, 'handle')
        subscriber_3.handle(self.action)
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
    
class ActiveRectangleSubscriberTest(unittest.TestCase):
    def test_can_consume_understands_events_within_active_x_and_y(self):
        subscriber = actions.ActiveRectangleSubscriber(10, 30, 10, 10)
        action_within = actions.Action(actions.LEFT_CLICK, 15, 35)
        action_out_on_x = actions.Action(actions.LEFT_CLICK, 25, 35)
        action_out_on_y = actions.Action(actions.LEFT_CLICK, 15, 15)
        action_out_on_both = actions.Action(actions.LEFT_CLICK, 30, 5)
        self.assertTrue(subscriber.can_consume(action_within))
        self.assertFalse(subscriber.can_consume(action_out_on_x))
        self.assertFalse(subscriber.can_consume(action_out_on_y))
        self.assertFalse(subscriber.can_consume(action_out_on_both))

    def test_should_affect_identity_based_equality(self):
        subscriber = actions.ActiveRectangleSubscriber(10, 30, 10, 10)
        self.assertEqual(subscriber, subscriber)

    def test_considers_key_events_non_consumable(self):
        subscriber = actions.ActiveRectangleSubscriber(10, 30, 10, 10)
        key_action = actions.Action(actions.KEY, 60, 60)
        self.assertFalse(subscriber.can_consume(key_action))

if __name__ == '__main__':
    unittest.main()
