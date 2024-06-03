# MNIST-Handwritten-Digit-Recognizer
A project for recognizing handwritten digit images captured by a mobile camera.

## Changelog

### 2024-06-03
- Implemented image processing pipeline for handwritten digit recognition:
  - Added file selection and image loading functionality
  - Applied Gaussian blur and morphological transformations
  - Performed adaptive thresholding and noise removal
  - Implemented Canny edge detection and Hough transform for line detection
  - Corrected image rotation based on the longest detected line
  - Filtered connected components by size
  - Drew bounding boxes around detected digits

