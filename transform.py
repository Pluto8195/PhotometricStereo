import cv2
import numpy as np
import sys

folder = sys.argv[1]
print (folder)

drawing = False # true if mouse is pressed
mode = True # if True, draw rectangle. Press 'm' to toggle to curve
ix,iy = -1,-1
pts1 = []

# mouse callback function
def draw_circle(event,x,y,flags,param):
  global ix,iy,drawing,mode

  if event == cv2.EVENT_LBUTTONDOWN:
    cv2.circle(img,(x,y),1,(0,0,255),-1)
    pts1.append([int(x/scalefactor), int(y/scalefactor)])
    print(x,y)
    print(x/scalefactor, y/scalefactor)


print(folder + 'albedo.jpg')
img = cv2.imread(folder + 'albedo.jpg',1)
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


pts1 = np.float32(pts1)
print(pts1)

pts2 = [ pts1[0], [ pts1[0,0], pts1[2,1] ], pts1[2], [ pts1[2,0], pts1[0,1]] ]
pts2 = np.float32(pts2)
print(pts2)


M = cv2.getPerspectiveTransform(pts1,pts2)
dst = cv2.warpPerspective(imgold,M,(width,height))

i1 = cv2.imread(folder + '_1.jpg', 1)
i2 = cv2.imread(folder + '_2.jpg', 1)
i3 = cv2.imread(folder + '_3.jpg', 1)
albedo = cv2.imread(folder + 'albedo.jpg', 1)

cv2.imwrite(folder + 'original_1.jpg', i1)
cv2.imwrite(folder + 'original_2.jpg', i2)
cv2.imwrite(folder + 'original_3.jpg', i3)
cv2.imwrite(folder + 'original_albedo.jpg', albedo)

i1 = cv2.warpPerspective(i1 ,M,(width,height))
i2 = cv2.warpPerspective(i2 ,M,(width,height))
i3 = cv2.warpPerspective(i3 ,M,(width,height))

cv2.imwrite(folder + 'affine_1.jpg', i1)
cv2.imwrite(folder + 'affine_2.jpg', i2)
cv2.imwrite(folder + 'affine_3.jpg', i3)

cv2.imwrite(folder + 'affine_albedo.jpg', dst)

cv2.destroyAllWindows()

