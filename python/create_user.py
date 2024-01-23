#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.firefox.options import Options  # Import Firefox options
import os

print(" Initialize a WebDriver (assuming you have the appropriate WebDriver installed)")
firefox_options = Options()
firefox_options.headless = True  # Set headless mode
firefox_options.add_argument("--disable-gpu")  # Disable GPU acceleration, often needed in headless mode

# Use the Firefox WebDriver
browser = webdriver.Firefox(options=firefox_options)

UPTIME_IP = os.environ.get("UPTIME_IP")

print(" Open the Uptime Kuma setup page")
url = f"http://{UPTIME_IP}:3001/"
browser.get(url)

if "setup" in browser.current_url:
    print(" Find the username, password, and repeat password fields")
    username_field = browser.find_element(By.ID, "floatingInput")
    password_field = browser.find_element(By.ID, "floatingPassword")
    repeat_password_field = browser.find_element(By.ID, "repeat")

    print(" Fill in the fields")
    username_field.send_keys(os.environ.get("UPTIME_USERNAME"))
    password_field.send_keys(os.environ.get("UPTIME_PASSWORD"))
    repeat_password_field.send_keys(os.environ.get("UPTIME_PASSWORD"))

    print(" Find and click the Create button")
    create_button = browser.find_element(By.XPATH, '//button[@data-cy="submit-setup-form"]')
    create_button.click()
else:
    print("User already exists")

print(" Close the WebDriver")
browser.quit()
