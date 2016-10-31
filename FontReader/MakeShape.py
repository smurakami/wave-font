import cv2
import numpy as np
from matplotlib import pyplot as plt
import sys
import json


def main():
    if len(sys.argv) < 3:
        print "usage: python MakeShape.py input_image output_json"
    input_image = sys.argv[1]
    output_json = sys.argv[2]

    image_original = cv2.imread(input_image)
    image = image_original.copy()
    image = cv2.cvtColor(image, cv2.cv.CV_RGB2GRAY)
    image = cv2.GaussianBlur(image,(11,11),0)
    th, image = cv2.threshold(image,127,255,cv2.THRESH_BINARY_INV)

    contours, hierarchy = cv2.findContours(image, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)

    json.dump([[c.tolist() for c in contours], hierarchy.tolist()], open(output_json, 'w'))


main()
