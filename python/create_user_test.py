#!/usr/bin/env python3
import unittest
from unittest.mock import patch, MagicMock
from selenium.webdriver.firefox.webdriver import WebDriver
from create_users import create_user

class TestCreateUser(unittest.TestCase):
    @patch('create_users.webdriver.Firefox')
    def test_create_user(self, mock_driver):
        # Create a mock WebDriver instance
        mock_webdriver = MagicMock(spec=WebDriver)
        mock_driver.return_value = mock_webdriver

        # Set up environment variables for testing
        mock_environ = {
            "UPTIME_USERNAME": "testuser",
            "UPTIME_PASSWORD": "testpassword"
        }

        with patch.dict('os.environ', mock_environ):
            create_user()

        # Ensure that the expected WebDriver methods were called
        mock_driver.assert_called_once_with(options=unittest.mock.ANY)
        mock_webdriver.get.assert_called_once_with("http://0.0.0.0:3001/")
        mock_webdriver.find_element.assert_called_once_with(unittest.mock.ANY, "floatingInput")
        mock_webdriver.quit.assert_called_once()

if __name__ == '__main__':
    unittest.main()

