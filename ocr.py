import cv2
import pytesseract
import numpy as np

img = cv2.imread('test.jpg')

# Custom options
custom_config = r'-l kor --oem 3 --psm 6'

print(pytesseract.image_to_string(img, config=custom_config))