import unittest
import env
from util import actions
import mox
from common import button
from util import actions
import zorder
import pygame

class ButtonTest(unittest.TestCase):
    class DummyOwner():
        def on_click(self):
            pass

    def setUp(self):
        pygame.display.set_mode((10, 10))
        self.dummy_owner = self.DummyOwner()
        self.publisher = actions.Publisher()
        self.dimensions = {'x' : 5, 'y' : 6, 'dx' : 7, 'dy' : 8}

    def test_has_image(self):
        button_instance = button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions)
        self.assertTrue(button_instance.image != None)
        self.assertTrue(isinstance(button_instance.image, pygame.Surface))
    
    def test_has_rect(self):
        button_instance = button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions)
        self.assertTrue(button_instance.source_rect != None)
        self.assertTrue(isinstance(button_instance.source_rect, pygame.Rect))

    def test_is_sprite(self):
        button_instance = button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions)
        self.assertTrue(isinstance(button_instance, pygame.sprite.DirtySprite))

    def test_is_active_rect(self):
        button_instance = button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions)
        self.assertTrue(isinstance(button_instance, actions.ActiveRectangleSubscriber))

    def test_notifies_owner_on_handle(self):
        owner = mox.MockObject(self.DummyOwner)
        owner.on_click()
        mox.Replay(owner)
        button_instance = button.Button(owner, 'on_click', self.publisher, **self.dimensions)
        button_instance.handle(object())
        mox.Verify(owner)

    def test_defaults_and_respects_users_z(self):
        self.assertEqual(button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions).layer, zorder.BUTTONS)
        self.dimensions['layer'] = 5
        self.assertEqual(button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions).layer, 5)

    def test_sets_dimensions_and_position(self):
        button_instance = button.Button(self.dummy_owner, 'on_click', self.publisher, x = 5, y = 6, dx = 3, dy = 2)
        self.assertEqual(button_instance.x(), 5)
        self.assertEqual(button_instance.y(), 6)
        self.assertEqual(button_instance.dx(), 3)
        self.assertEqual(button_instance.dy(), 2)

    def test_does_not_start_activated(self):
        button_instance = button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions)
        event = actions.Action(actions.LEFT_CLICK, 8, 8)
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(button_instance, 'handle')
        mock_factory.ReplayAll()
        self.publisher.publish(event)
        mock_factory.VerifyAll()

    def test_receives_events_when_activated(self):
        button_instance = button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions)
        event = actions.Action(actions.LEFT_CLICK, 8, 8)
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(button_instance, 'handle')
        button_instance.handle(event)
        mock_factory.ReplayAll()
        button_instance.activate()
        self.publisher.publish(event)
        mock_factory.VerifyAll()

    def test_does_not_receive_events_when_deactivated(self):
        button_instance = button.Button(self.dummy_owner, 'on_click', self.publisher, **self.dimensions)
        event = actions.Action(actions.LEFT_CLICK, 8, 8)
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(button_instance, 'handle')
        mock_factory.ReplayAll()
        button_instance.deactivate()
        button_instance.activate()
        button_instance.deactivate()
        self.publisher.publish(event)
        mock_factory.VerifyAll()

if __name__ == '__main__':
    unittest.main()