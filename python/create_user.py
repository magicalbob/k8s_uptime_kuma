#!/usr/bin/env python
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import os

# Initialize a WebDriver (assuming you have the appropriate WebDriver installed)
browser = webdriver.Chrome()

UPTIME_IP=os.environ.get("UPTIME_IP")

# Open the Uptime Kuma setup page
url = f"http://{UPTIME_IP}:3001/setup"
browser.get(url)

# Find the username, password, and repeat password fields
username_field = browser.find_element(By.ID, "floatingInput")
password_field = browser.find_element(By.ID, "floatingPassword")
repeat_password_field = browser.find_element(By.ID, "repeat")

# Fill in the fields
username_field.send_keys(os.environ.get("UPTIME_USERNAME"))
password_field.send_keys(os.environ.get("UPTIME_PASSWORD"))
repeat_password_field.send_keys(os.environ.get("UPTIME_PASSWORD"))

# Find and click the "Create" button
create_button = browser.find_element(By.XPATH, '//button[@data-cy="submit-setup-form"]')
create_button.click()

# Optionally, you can add code to wait for the registration to complete or handle any success/error messages

# Close the WebDriver
browser.quit()

