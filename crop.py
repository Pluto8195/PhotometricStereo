import cv2
import numpy as np
import sys

folder = sys.argv[1]
print (folder)

drawing = False # true if mouse is pressed
mode = True # if True, draw rectangle. Press 'm' to toggle to curve
ix,iy = -1,-1

# mouse callback function
def draw_circle(event,x,y,flags,param):
  global ix,iy,ex,ey,drawing,mode

  if event == cv2.EVENT_LBUTTONDOWN:
    drawing = True
    ix,iy = x,y

  elif event == cv2.EVENT_MOUSEMOVE:
    if drawing == True:
      cv2.rectangle(img,(ix,iy),(x,y),(0,255,0),-1)
     
  elif event == cv2.EVENT_LBUTTONUP:
    drawing = False
    ex,ey = x,y
    cv2.rectangle(img,(ix,iy),(x,y),(0,255,0),-1)
  


print(folder + 'affine_albedo.jpg')
img = cv2.imread(folder + 'affine_albedo.jpg',1)
imgold = img
height, width, channels = img.shape
if height > width:
  scalefactor = 800/float(height)
  newWidth = width*scalefactor
  resized = cv2.resize(img, (int(newWidth), 800))
else:
  scalefactor = 800/float(width)
  newHeight = width*scalefactor
  resized = cv2.resize(img, (1000, int(newHeight)))

img = resized

cv2.namedWindow('image')
cv2.setMouseCallback('image',draw_circle)

while(1):
    cv2.imshow('image',img)
    k = cv2.waitKey(1) & 0xFF
    if k == ord('m'):
      mode = not mode
    elif k == 27:
      break


print(ix,iy)
print(ex,ey)

crop_img = imgold[int(iy/scalefactor):int(ey/scalefactor), int(ix/scalefactor):int(ex/scalefactor)]

i1 = cv2.imread(folder + 'affine_1.jpg', 1)
i2 = cv2.imread(folder + 'affine_2.jpg', 1)
i3 = cv2.imread(folder + 'affine_3.jpg', 1)

i1 = i1[int(iy/scalefactor):int(ey/scalefactor), int(ix/scalefactor):int(ex/scalefactor)]
i2 = i2[int(iy/scalefactor):int(ey/scalefactor), int(ix/scalefactor):int(ex/scalefactor)]
i3 = i3[int(iy/scalefactor):int(ey/scalefactor), int(ix/scalefactor):int(ex/scalefactor)]



cv2.imwrite(folder + 'final_1.jpg', i1)
cv2.imwrite(folder + 'final_2.jpg', i2)
cv2.imwrite(folder + 'final_3.jpg', i3)

cv2.imwrite(folder + 'albedo.jpg', crop_img)
cv2.destroyAllWindows()

