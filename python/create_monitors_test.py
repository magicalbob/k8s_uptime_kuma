#!/usr/bin/env python3
import unittest
from unittest.mock import patch, MagicMock
from create_users import create_monitors

class TestCreateMonitors(unittest.TestCase):
    @patch('create_users.UptimeKumaApi')
    @patch('builtins.open', new_callable=unittest.mock.mock_open)
    @patch('json.load')
    @patch('os.environ', {"UPTIME_URL": "http://testurl", "UPTIME_USERNAME": "testuser", "UPTIME_PASSWORD": "testpassword"})
    def test_create_monitors(self, mock_json_load, mock_open, mock_api):
        # Mock the UptimeKumaApi instance
        mock_api_instance = MagicMock()
        mock_api.return_value = mock_api_instance

        # Mock the monitor data from the JSON file
        mock_monitor_data = [
            {
                "name": "Monitor1",
                "url": "http://example.com",
                "type": "http",
                "expiryNotification": True,
                "ignoreTls": True
            },
            {
                "name": "Monitor2",
                "url": "http://example2.com",
                "type": "http",
                "expiryNotification": False,
                "ignoreTls": False
            }
        ]

        mock_json_load.return_value = mock_monitor_data

        # Run the create_monitors function
        create_monitors()

        # Assertions
        mock_api.assert_called_once_with("http://testurl")
        mock_api_instance.login.assert_called_once_with("testuser", "testpassword")
        mock_api_instance.add_monitor.assert_called_with(
            name="Monitor1",
            url="http://example.com",
            type="http",
            expiryNotification=True,
            ignoreTls=True
        )
        mock_api_instance.add_monitor.assert_called_with(
            name="Monitor2",
            url="http://example2.com",
            type="http",
            expiryNotification=False,
            ignoreTls=False
        )
        mock_api_instance.logout.assert_called_once()

if __name__ == '__main__':
    unittest.main()

