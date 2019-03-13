#include <iostream>
#include <vector>
#include <cmath>
#include <time.h> 

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>


using namespace cv;
using namespace std;


//TODO: 
// 1. Change pyrDown for a resize solution that doesnt blur
// 2. Define better cost function, not just about the sum of differences on pixels but how evenly they are distributed

Mat& ScanImage(Mat& I);
Mat& ComputeNormal(Mat& A, Mat& B, Mat& C, Mat& O, int th, Mat& S);
Mat& GenerateRandomCalibration(Mat& I);
Mat& GenerateRandomNeighbor(Mat& I);
long int CalculateCost(Mat& I);



int main( int argc, char* argv[]) {

  if (argc < 4) {
      
    cout << "Not enough parameters" << endl;
    cout << "How to use: \n" << "'/Path/To/Folder' 'threshold(int)' 'iterations(int)'"; 
    return -1;

  }

  Mat A, B, C, tmp;

  int iterations = stoi(argv[3]);

  Mat a = imread(argv[1]+string("/final_1.jpg"), IMREAD_GRAYSCALE);
  Mat b = imread(argv[1]+string("/final_2.jpg"), IMREAD_GRAYSCALE);
  Mat c = imread(argv[1]+string("/final_3.jpg"), IMREAD_GRAYSCALE);
  
  
  A = imread(argv[1]+string("/final_1.jpg"), IMREAD_GRAYSCALE);
  //TODO: change pyrDown for a resize solution that doesnt blur
  pyrDown(A, tmp, Size(A.cols/2, A.rows/2));
  A = tmp.clone();
  pyrDown(A, tmp, Size(A.cols/2, A.rows/2));
  A = tmp.clone();
  pyrDown(A, tmp, Size(A.cols/2, A.rows/2));
  A = tmp.clone();

  B = imread(argv[1]+string("/final_2.jpg"), IMREAD_GRAYSCALE);
  pyrDown(B, tmp, Size(B.cols/2, B.rows/2));
  B = tmp.clone();
  pyrDown(B, tmp, Size(B.cols/2, B.rows/2));
  B = tmp.clone();
  pyrDown(B, tmp, Size(B.cols/2, B.rows/2));
  B = tmp.clone();

  C = imread(argv[1]+string("/final_3.jpg"), IMREAD_GRAYSCALE);
  pyrDown(C, tmp, Size(C.cols/2, C.rows/2));
  C = tmp.clone();
  pyrDown(C, tmp, Size(C.cols/2, C.rows/2));
  C = tmp.clone();
  pyrDown(C, tmp, Size(C.cols/2, C.rows/2));
  C = tmp.clone();

  int threshold = stoi(argv[2]);


  Mat O(A.rows,A.cols, CV_8UC3, Scalar(0,0,0));
  Mat o(a.rows,a.cols, CV_8UC3, Scalar(0,0,0));


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


  Mat CalibOld(3, 3, CV_8SC1, Scalar(0));
  Mat CalibNew(3, 3, CV_8SC1, Scalar(0));

  long int costOld = 0;
  long int costNew = 0;

  Mat C_clone = CalibOld.clone();

  CalibOld = GenerateRandomCalibration(C_clone);


  O = ComputeNormal(A, B, C, O, threshold, CalibOld);
  costOld = CalculateCost(O);

  for(int i = 0; i < iterations; i++) {

    C_clone = CalibOld.clone();
    CalibNew = GenerateRandomNeighbor(C_clone);

    O = ComputeNormal(A, B, C, O, threshold, CalibNew);
    costNew = CalculateCost(O);
    
    if(costNew < costOld) {
      cout << costNew << "\n";
      namedWindow( "Display window", WINDOW_AUTOSIZE );// Create a window for display.
      imshow( "Display window", O );    
      waitKey(10);
      costOld = costNew;
      CalibOld = CalibNew.clone();
    }


  } 
  

  o = ComputeNormal(a, b, c, o, threshold, CalibOld);

  imwrite(argv[1]+string("/normal_")+to_string(threshold)+"_"+to_string(iterations)+(".jpg"), o);
  



  srand (time(NULL));
  
  return 0;
}

Mat& GenerateRandomCalibration(Mat& I) {

  int i,j;
  int nRows = I.rows;
  int nCols = I.cols;

  
  for( i = 0; i < nRows; ++i) {
    for ( j = 0; j < nCols; ++j) {
      //generate random integer from -50 to 300
      if(j == 0) {
        I.at<uchar>(i,j) = (rand() % 75) - 50;
      } else {
        I.at<uchar>(i,j) = (rand() % 200);
      }
    }
  }

  return I;

}

Mat& GenerateRandomNeighbor(Mat& I) {
  
  int i,j;
  int nRows = I.rows;
  int nCols = I.cols;

  i = rand() % 3;
  j = rand() % 3;
  
  if(j == 0) {
    I.at<uchar>(i,j) = (rand() % 75) - 50;
  } else {
    I.at<uchar>(i,j) = (rand() % 200);
  }
  
  return I;

}

long int CalculateCost(Mat& I) {

  // accept only char type matrices
  CV_Assert(I.depth() == CV_8U);

  int channels = I.channels();

  int nRows = I.rows;
  int nCols = I.cols;

  int cost = 0;


  long i,j;
  uchar* p;
  for( i = 0; i < nRows; ++i) {

    const uchar *p = I.ptr(i);
    for ( j = 0; j < nCols; ++j) {

      const uchar * byte = p;
      cost += 255-(int)byte[0];
      cost += abs(125-(int)byte[1]);
      cost += abs(125-(int)byte[2]);

      p += 3;
      
    }
  }
  
  return cost;
}











Mat& ComputeNormal(Mat& A, Mat& B, Mat& C, Mat& O, int th, Mat& S) {

  //what is Threashold for again?
  
  /*
    Assert that size of all Mat are the same
    if not? throw warning but use bounds of smalles Mat
  */


  double Sinv[3][3];

  //Determinant and Inverse algorithm taken from www.thecrazyprogramer.com
  float determinant = 0;
  for(int i = 0; i < 3; i++) {
    determinant = determinant + 
    ( 
      (int)S.at<uchar>(0,i)  * 
        ( 
          (int)S.at<uchar>(1,(i+1)%3)  * 
          (int)S.at<uchar>(2,(i+2)%3)  - 
          (int)S.at<uchar>(1,(i+2)%3)  * 
          (int)S.at<uchar>(2,(i+1)%3) 
        )
    );      

    // DONT DELETE
    // determinant = determinant + (source[0][i] * (source[1][(i+1)%3] * source[2][(i+2)%3] - source[1][(i+2)%3] * source[2][(i+1)%3]));      
  }


  for(int i = 0; i < 3; i++) {
    for(int j = 0; j < 3; j++) {
      Sinv[i][j] = (((int)S.at<uchar>( (j+1)%3, (i+1)%3 ) * (int)S.at<uchar>( (j+2)%3, (i+2)%3 )) - ((int)S.at<uchar>( (j+1)%3, (i+2)%3 ) * (int)S.at<uchar>( (j+2)%3, (i+1)%3 )))/determinant;
    }
  }
  

  //current assumption use only grayscale image
  int nRows = A.rows;
  int nCols = A.cols;
  if (A.isContinuous()) {

    nCols *= nRows;
    nRows = 1;
    
  }

  int i,j;
  uchar* p1;
  uchar* p2;
  uchar* p3;

  uchar* o;

  double maxR = 0, minR = 255, maxB = 0, minB = 255, maxG = 0, minG = 255;

  for( i = 0; i < nRows; ++i) {

    //pn are full rows we index rows like p[j]
    p1 = A.ptr<uchar>(i);
    p2 = B.ptr<uchar>(i);
    p3 = C.ptr<uchar>(i);

    o = O.ptr<uchar>(i);
    
    for ( j = 0; j < nCols; ++j) {
      int I[3];

      //get pixels across all 3 images
      I[0] = (int)p1[j];
      I[1] = (int)p2[j];
      I[2] = (int)p3[j];

      double N[3];
      double n[3];
      double mag = 0;

      if(I[0] > th && I[1] > th && I[2] > th) {

        //Compute N
        N[0] = Sinv[0][0]*I[0] + Sinv[0][1]*I[1] + Sinv[0][2]*I[2]; 
        N[1] = Sinv[1][0]*I[0] + Sinv[1][1]*I[1] + Sinv[1][2]*I[2]; 
        N[2] = Sinv[2][0]*I[0] + Sinv[2][1]*I[1] + Sinv[2][2]*I[2];

        mag = sqrt(pow(N[0],2)+pow(N[1],2)+pow(N[2],2));
        n[0] = ((N[0]/mag)+1)*127.5;
        n[1] = ((N[1]/mag)+1)*127.5;
        n[2] = ((N[2]/mag)+1)*127.5;


        o[j*3] = n[2];
        o[j*3 +1 ] = n[1];
        o[j*3 +2 ] = n[0];
       


        if(n[0] > maxB) maxB = n[0];
        if(n[0] < minB) minB = n[0];

        if(n[1] > maxG) maxG = n[1];
        if(n[1] < minG) minG = n[1];

        if(n[2] > maxR) maxR = n[2];
        if(n[2] < minR) minR = n[2];

      } else {
        o[j*3] = 255;
        o[j*3 +1 ] = 125;
        o[j*3 +2 ] = 125;
      }

    }
  }

  return O;
}




