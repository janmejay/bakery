import unittest
import env
import bakery_wizard
import mox
import pygame
from util import actions

class BakeryWizardTest(unittest.TestCase):
    def setUp(self):
        self.bakery_wizard = bakery_wizard.BakeryWizard()

    def test_initializes_pygame_display_while_creating_bakery_wizard(self):
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(pygame.display, 'set_mode')
        screen = object()
        pygame.display.set_mode((1024, 768)).AndReturn(screen)
        mock_factory.ReplayAll()
        new_bakery_wizard = bakery_wizard.BakeryWizard()
        mock_factory.VerifyAll()
        self.assertEqual(new_bakery_wizard.screen, screen)

    def test_sets_up_current_window_as_given_window_and_marks_window_as_changed(self):
        mock_factory = mox.Mox()
        window = mock_factory.CreateMock(bakery_wizard.BaseWindow)
        self.assertFalse(self.bakery_wizard.window_changed)
        window.load(self.bakery_wizard.screen)
        mock_factory.ReplayAll()
        self.bakery_wizard.show(window)
        mock_factory.VerifyAll()
        self.assertEqual(self.bakery_wizard.current_window, window)
        self.assertTrue(self.bakery_wizard.window_changed)

    def test_uses_continue_game_loop_for_predicate_continue_looping(self):
        self.bakery_wizard.continue_game_loop = True
        self.assertTrue(self.bakery_wizard.continue_looping())
        self.bakery_wizard.continue_game_loop = False
        self.assertFalse(self.bakery_wizard.continue_looping())

    def test_stop_stops_the_game_loop(self):
        self.bakery_wizard.continue_game_loop = True
        self.assertTrue(self.bakery_wizard.continue_looping())
        self.bakery_wizard.stop()
        self.assertFalse(self.bakery_wizard.continue_looping())

    def test_initializes_pygame_and_sets_display(self):
        wizard_instance = bakery_wizard.BakeryWizard()
        mock_factory = mox.Mox()
        mock_factory.StubOutWithMock(pygame.display, 'flip')
        mock_factory.StubOutWithMock(wizard_instance, 'continue_looping')
        mock_factory.StubOutWithMock(pygame.event, 'get')
        mock_factory.StubOutWithMock(actions, 'actionsFor')
        screen = mock_factory.CreateMock(pygame.surface.Surface)
        window = mock_factory.CreateMock(bakery_wizard.BaseWindow)
        evt = object()
        action = object()
        
        wizard_instance.screen = screen
        window.load(screen)
        wizard_instance.continue_looping().AndReturn(True)
        window.draw()
        pygame.event.get().AndReturn(evt)
        actions.actionsFor(evt).AndReturn([action])
        window.publish(action)
        pygame.display.flip()
        wizard_instance.continue_looping().AndReturn(False)

        mock_factory.ReplayAll()
        wizard_instance.show(window)
        wizard_instance.start()
        mock_factory.VerifyAll()

if __name__ == "__main__":
    unittest.main()

