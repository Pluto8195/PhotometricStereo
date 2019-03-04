#include <iostream>
#include <vector>
#include <cmath>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>


using namespace cv;
using namespace std;

Mat& ScanImage(Mat& I);
int * FindCentroid(Mat& I);
void GetCalibration(Mat& I, int params[3], double n[]);


int main( int argc, char* argv[]) {

  if (argc < 5) {
      
    cout << "Not enough parameters" << endl;
    return -1;

  }

  Mat I, A, B, C;

  I = imread(argv[1], IMREAD_GRAYSCALE);
  A = imread(argv[2], IMREAD_GRAYSCALE);
  B = imread(argv[3], IMREAD_GRAYSCALE);
  C = imread(argv[4], IMREAD_GRAYSCALE);
  double th = (double)stoi(argv[5]);



  if (!I.data) {
    cout << "The image" << argv[1] << " could not be loaded." << endl;
    return -1;
  }

  if (!A.data) {
    cout << "The image" << argv[2] << " could not be loaded." << endl;
    return -1;
  }

  if (!B.data) {
    cout << "The image" << argv[3] << " could not be loaded." << endl;
    return -1;
  }

  if (!C.data) {
    cout << "The image" << argv[4] << " could not be loaded." << endl;
    return -1;
  }

  Mat O = I.clone();

  threshold(I, O, th, 255.0, 0);

  imwrite("binerized.jpg", O);

 
  int * params = FindCentroid(O);

  double calibration[3][3];

  GetCalibration(A, params, calibration[0]);
  GetCalibration(B, params, calibration[1]);
  GetCalibration(C, params, calibration[2]);



 
  return 0;
}



//Sum up center of mass of a binerized image
int * FindCentroid(Mat& I) {

  int i,j;

  int nRows = I.rows;
  int nCols = I.cols;

  int area = 0;
  int i_sum = 0, j_sum = 0;
  int top = nRows;
  int bot = 0;
  int left = nCols;
  int right = 0;

  uchar* p;
  for( i = 0; i < nRows; ++i) {
    for ( j = 0; j < nCols; ++j) {
      int byte = (int)I.at<uchar>(i,j);
      if(byte == 255) {
        if(i < top) top = i;
        if(i > bot) bot = i;
        if(j < right) right = j;
        if(j > left) left = j;
        area ++;
        i_sum += i;
        j_sum += j;
      }
    }
  }

  //compute radius
  int radius = abs((((bot-top)+(right-left))/2)/2);


  int i_coord = i_sum/area;
  int j_coord = j_sum/area;

  static int parameters[3] = {i_coord, j_coord, radius};

  return parameters;
}


void GetCalibration(Mat& I, int params[3], double n[]) {

  int i,j;
  int nRows = I.rows;
  int nCols = I.cols;

  int i_coord = params[0];
  int j_coord = params[1];
  int radius = params[2];

  int max = 0, i_max = 0, j_max = 0;
  
  for( i = 0; i < nRows; ++i) {
    for ( j = 0; j < nCols; ++j) {
      int byte = (int)I.at<uchar>(i,j);
      
      if(byte > max) {
        max = byte;
        i_max = i;
        j_max = j;
      }
    }
  }

  double normal[3];
  normal[0] = i_max-i_coord;
  normal[1] = j_max-j_coord;

  //compute Z of normal vector using (Z^2 = R^2-X^2-Y^2)
  int result = pow(radius,2)-pow(normal[0],2)-pow(normal[1],2);
  if(result < 0) {
    normal[2] = -sqrt(-result);
  } else {
    normal[2] = sqrt(result);
  }


  int mag = sqrt(pow(normal[0],2)+pow(normal[1],2)+pow(normal[2],2));


  //normalized vector scaled by the intensity of the pixel
  n[0] = (normal[0]/mag)*max;
  n[1] = (normal[1]/mag)*max;
  n[2] = (normal[2]/mag)*max;


  cout << n[0] << "\n";
  cout << n[1] << "\n";
  cout << n[2] << "\n";

}
