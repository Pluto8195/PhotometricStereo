#include <iostream>
#include <vector>
#include <cmath>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>


using namespace cv;
using namespace std;

Mat& getHighlight(Mat& I, int th);


int main( int argc, char* argv[]) {

  if (argc < 2) {
      
    cout << "Not enough parameters" << endl;
    return -1;

  }

  int th = stoi(argv[2]);

  Mat A, B, C, I, O;

  A = imread(argv[1]+string("/_1.jpg"), IMREAD_COLOR);
  B = imread(argv[1]+string("/_2.jpg"), IMREAD_COLOR);
  C = imread(argv[1]+string("/_3.jpg"), IMREAD_COLOR);


  if (!A.data) {
    cout << "The image: " << argv[1] << " could not be loaded." << endl;
    return -1;
  }

  if (!B.data) {
    cout << "The image: " << argv[1] << " could not be loaded." << endl;
    return -1;
  }

  if (!C.data) {
    cout << "The image: " << argv[1] << " could not be loaded." << endl;
    return -1;
  }

  O = A.clone();
  O = getHighlight(A, th);
  imwrite(argv[1]+string("/highlight1.jpg"), O);

  O = B.clone();
  B = getHighlight(B, th);
  imwrite(argv[1]+string("/highlight2.jpg"), B);

  O = C.clone();
  C = getHighlight(C, th);
  imwrite(argv[1]+string("/highlight3.jpg"), C);
 
  return 0;
}

Mat& getHighlight(Mat& I, int th) {

  // accept only char type matrices
  CV_Assert(I.depth() == CV_8U);

  int channels = I.channels();

  int nRows = I.rows;
  int nCols = I.cols * channels;

  if (I.isContinuous()) {
    nCols *= nRows;
    nRows = 1;
  }

  int i,j;
  
  uchar* p;
  for( i = 0; i < nRows; ++i) {

  
    p = I.ptr<uchar>(i);
    for ( j = 0; j < nCols; ++j) {

      if(p[j*3] > th && p[j*3 +1] > th && p[j*3 +2] > th) {
        p[j*3] = 255;
        p[j*3 +1] = 255;
        p[j*3 +2] = 255;
      } else {
        p[j*3] = 0;
        p[j*3 +1] = 0;
        p[j*3 +2] = 0;
      }
      
    }
  }

  return I;

}


