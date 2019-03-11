#include <iostream>
#include <vector>
#include <cmath>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>


using namespace cv;
using namespace std;

Mat& AverageImages(Mat& A, Mat& B, Mat& C, Mat& I);


int main( int argc, char* argv[]) {

  if (argc < 1) {
      
    cout << "Not enough parameters" << endl;
    return -1;

  }

  Mat A, B, C, I, O;

  A = imread(argv[1]+string("/_1.jpg"), IMREAD_COLOR);
  B = imread(argv[1]+string("/_2.jpg"), IMREAD_COLOR);
  C = imread(argv[1]+string("/_3.jpg"), IMREAD_COLOR);
  I = A.clone();



  if (!A.data) {
    cout << "The image" << argv[1] << " could not be loaded." << endl;
    return -1;
  }

  if (!B.data) {
    cout << "The image" << argv[1] << " could not be loaded." << endl;
    return -1;
  }

  if (!C.data) {
    cout << "The image" << argv[1] << " could not be loaded." << endl;
    return -1;
  }

  O = AverageImages(A, B, C, I);

  imwrite(argv[1]+string("/albedo.jpg"), O);
 
  return 0;
}

Mat& AverageImages(Mat& A, Mat& B, Mat& C, Mat& I) {

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
  uchar* pA;
  uchar* pB;
  uchar* pC;
  uchar* pI;
  for( i = 0; i < nRows; ++i) {

    pA = A.ptr<uchar>(i);
    pB = B.ptr<uchar>(i);
    pC = C.ptr<uchar>(i);
    pI = I.ptr<uchar>(i);
    for ( j = 0; j < nCols; ++j) {

      pI[j] = ( pA[j] + pB[j] + pC[j] ) / 3;

    }
  }

  return I;

}


