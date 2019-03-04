

#include <iostream>
#include <vector>
#include <cmath>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>


using namespace cv;
using namespace std;


static void help()
{
    cout
        << "\n--------------------------------------------------------------------------" << endl
        << "This program shows how to scan image objects in OpenCV (cv::Mat). As use case"
        << " we take an input image and divide the native color palette (255) with the "  << endl
        << "input. Shows C operator[] method, iterators and at function for on-the-fly item address calculation."<< endl
        << "Usage:"                                                                       << endl
        << "./howToScanImages imageNameToUse divideWith [G]"                              << endl
        << "if you add a G parameter the image is processed in gray scale"                << endl
        << "--------------------------------------------------------------------------"   << endl
        << endl;
}

Mat& ScanImageAndReduceC(Mat& I, const uchar* table);
Mat& ScanImageAndReduceIterator(Mat& I, const uchar* table);
Mat& ScanImageAndReduceRandomAccess(Mat& I, const uchar * table);

int main( int argc, char* argv[])
{
    help();
    if (argc < 3)
    {
        cout << "Not enough parameters" << endl;
        return -1;
    }

    Mat I, J;
    if( argc == 4 && !strcmp(argv[3],"G") )
        I = imread(argv[1], IMREAD_GRAYSCALE);
    else
        I = imread(argv[1], IMREAD_COLOR);

    if (!I.data)
    {
        cout << "The image" << argv[1] << " could not be loaded." << endl;
        return -1;
    }

    int divideWith = 0; // convert our input string to number - C++ style
    stringstream s;
    s << argv[2];
    s >> divideWith;
    if (!s || !divideWith)
    {
        cout << "Invalid number entered for dividing. " << endl;
        return -1;
    }

    uchar table[256];
    for (int i = 0; i < 256; ++i)
       table[i] = (uchar)(divideWith * (i/divideWith));

    const int times = 100;
    double t;

    t = (double)getTickCount();

    for (int i = 0; i < times; ++i)
    {
        cv::Mat clone_i = I.clone();
        J = ScanImageAndReduceC(clone_i, table);
    }

    t = 1000*((double)getTickCount() - t)/getTickFrequency();
    t /= times;

    cout << "Time of reducing with the C operator [] (averaged for "
         << times << " runs): " << t << " milliseconds."<< endl;

    t = (double)getTickCount();

    for (int i = 0; i < times; ++i)
    {
        cv::Mat clone_i = I.clone();
        J = ScanImageAndReduceIterator(clone_i, table);
    }

    t = 1000*((double)getTickCount() - t)/getTickFrequency();
    t /= times;

    cout << "Time of reducing with the iterator (averaged for "
        << times << " runs): " << t << " milliseconds."<< endl;

    t = (double)getTickCount();

    for (int i = 0; i < times; ++i)
    {
        cv::Mat clone_i = I.clone();
        ScanImageAndReduceRandomAccess(clone_i, table);
    }

    t = 1000*((double)getTickCount() - t)/getTickFrequency();
    t /= times;

    cout << "Time of reducing with the on-the-fly address generation - at function (averaged for "
        << times << " runs): " << t << " milliseconds."<< endl;

    Mat lookUpTable(1, 256, CV_8U);
    uchar* p = lookUpTable.data;
    for( int i = 0; i < 256; ++i)
        p[i] = table[i];

    t = (double)getTickCount();

    for (int i = 0; i < times; ++i)
        LUT(I, lookUpTable, J);

    t = 1000*((double)getTickCount() - t)/getTickFrequency();
    t /= times;

    cout << "Time of reducing with the LUT function (averaged for "
        << times << " runs): " << t << " milliseconds."<< endl;
    return 0;
}

Mat& ScanImageAndReduceC(Mat& I, const uchar* const table)
{
    // accept only char type matrices
    CV_Assert(I.depth() == CV_8U);

    int channels = I.channels();

    int nRows = I.rows;
    int nCols = I.cols * channels;

    if (I.isContinuous())
    {
        nCols *= nRows;
        nRows = 1;
    }

    int i,j;
    uchar* p;
    for( i = 0; i < nRows; ++i)
    {
        p = I.ptr<uchar>(i);
        for ( j = 0; j < nCols; ++j)
        {
            p[j] = table[p[j]];
        }
    }
    return I;
}

Mat& ScanImageAndReduceIterator(Mat& I, const uchar* const table)
{
    // accept only char type matrices
    CV_Assert(I.depth() == CV_8U);

    const int channels = I.channels();
    switch(channels)
    {
    case 1:
        {
            MatIterator_<uchar> it, end;
            for( it = I.begin<uchar>(), end = I.end<uchar>(); it != end; ++it)
                *it = table[*it];
            break;
        }
    case 3:
        {
            MatIterator_<Vec3b> it, end;
            for( it = I.begin<Vec3b>(), end = I.end<Vec3b>(); it != end; ++it)
            {
                (*it)[0] = table[(*it)[0]];
                (*it)[1] = table[(*it)[1]];
                (*it)[2] = table[(*it)[2]];
            }
        }
    }

    return I;
}

Mat& ScanImageAndReduceRandomAccess(Mat& I, const uchar* const table)
{
    // accept only char type matrices
    CV_Assert(I.depth() == CV_8U);

    const int channels = I.channels();
    switch(channels)
    {
    case 1:
        {
            for( int i = 0; i < I.rows; ++i)
                for( int j = 0; j < I.cols; ++j )
                    I.at<uchar>(i,j) = table[I.at<uchar>(i,j)];
            break;
        }
    case 3:
        {
         Mat_<Vec3b> _I = I;

         for( int i = 0; i < I.rows; ++i)
            for( int j = 0; j < I.cols; ++j )
               {
                   _I(i,j)[0] = table[_I(i,j)[0]];
                   _I(i,j)[1] = table[_I(i,j)[1]];
                   _I(i,j)[2] = table[_I(i,j)[2]];
            }
         I = _I;
         break;
        }
    }

    return I;
}





void ComputeNeedles(Image &img1, Image &img2, Image &img3, int step, int th, string file_name) {
  const int num_rows = img1.num_rows();
  const int num_columns = img2.num_columns();
  const int graylevels = img3.num_gray_levels();

  //3 arrays of 3 values
  //x,y,z of source normal
  int source[3][3];


  ifstream file;
  file.open(file_name);
  string line;
  for(int i = 0; i < 3; i++) {
    getline(file,line);
    istringstream iss(line);

    iss >> line;
    source[i][0] = stoi(line);
    iss >> line;
    source[i][1] = stoi(line);
    iss >> line;
    source[i][2] = stoi(line);
  }


  file.close();
  

  double Sinv[3][3];

  //Determinant and Inverse algorithm taken from www.thecrazyprogramer.com
  float determinant = 0;
  for(int i = 0; i < 3; i++) {
    determinant = determinant + (source[0][i] * (source[1][(i+1)%3] * source[2][(i+2)%3] - source[1][(i+2)%3] * source[2][(i+1)%3]));      
  }


  for(int i = 0; i < 3; i++) {
    for(int j = 0; j < 3; j++) {
      Sinv[i][j] = ((source[(j+1)%3][(i+1)%3] * source[(j+2)%3][(i+2)%3]) - (source[(j+1)%3][(i+2)%3] * source[(j+2)%3][(i+1)%3]))/determinant;
    }
  }

  //iterate over all 
  for(int i = 0; i < num_rows; i+= step) {
    for(int j = 0; j < num_columns; j+= step) {
      int I[3];
      I[0] = img1.GetPixel(i,j);
      I[1] = img2.GetPixel(i,j);
      I[2] = img3.GetPixel(i,j);

      double N[3];
      double n[3];
      double mag = 0;

      if(I[0] > th && I[1] > th && I[2] > th) {

        //Compute N
        N[0] = Sinv[0][0]*I[0] + Sinv[0][1]*I[1] + Sinv[0][2]*I[2]; 
        N[1] = Sinv[1][0]*I[0] + Sinv[1][1]*I[1] + Sinv[1][2]*I[2]; 
        N[2] = Sinv[2][0]*I[0] + Sinv[2][1]*I[1] + Sinv[2][2]*I[2]; 

   
        mag = sqrt(pow(N[0],2)+pow(N[1],2)+pow(N[2],2));
        n[0] = (N[0]/mag)*10;
        n[1] = (N[1]/mag)*10;
        n[2] = (N[2]/mag)*10;

        //cout << N[0] << " " << N[1] << " " << N[2] << "\n";
        cout << n[0] << " " << n[1] << " " << n[2] << "\n";
        //cout << mag << " ";
        //DrawLine(i_max, j_max, i_max+normal[0], j_max+normal[1], 0, &an_image);
        DrawDot(img1, i, j, 0);
        DrawLine(i, j, i+n[0], j+n[1], 255, &img1);
      }


    }
  }
}


string ComputeNormal(Image &an_image, string file_name) {
  const int num_rows = an_image.num_rows();
  const int num_columns = an_image.num_columns();
  const int graylevels = an_image.num_gray_levels();

  ifstream file;
  file.open(file_name);
  string line;
  getline(file,line);
  istringstream iss(line);
  iss >> line;
  int i_coord = stoi(line);
  iss >> line;
  int j_coord = stoi(line);
  iss >> line;
  int radius = stoi(line);

  // cout << i_coord << "\n";
  // cout << j_coord << "\n";
  // cout << radius << "\n";

  file.close();

  int max = 0;
  int i_max = 0;
  int j_max = 0;
  for(int i = 0; i < num_rows; i++) {
    for(int j = 0; j < num_columns; j++) {
      int byte = an_image.GetPixel(i,j);
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
  normal[2] = sqrt(pow(radius,2)-pow(normal[0],2)-pow(normal[1],2));

  int mag = sqrt(pow(normal[0],2)+pow(normal[1],2)+pow(normal[2],2));
  
  //normalized vector scaled by the intensity of the pixel
  double n[3];
  n[0] = (normal[0]/mag)*max;
  n[1] = (normal[1]/mag)*max;
  n[2] = (normal[2]/mag)*max;


  string output = to_string(n[0]) + " " + to_string(n[1]) + " " + to_string(n[2]) + "\n";

  return output;

}



string FindCentroid(Image &an_image) {
  const int num_rows = an_image.num_rows();
  const int num_columns = an_image.num_columns();
  const int graylevels = an_image.num_gray_levels();

  int area = 0;
  int i_sum = 0;
  int j_sum = 0;
  int top = num_rows;
  int bot = 0;
  int left = num_columns;
  int right = 0;
  for(int i = 0; i < num_rows; i++) {
    for(int j = 0; j < num_columns; j++) {
      int byte = an_image.GetPixel(i,j);
      if(byte == 1) {
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
  int radius = (((bot-top)+(right-left))/2)/2;

  int i_coord = i_sum/area;
  int j_coord = j_sum/area;

  string file = to_string(i_coord) + " " + to_string(j_coord) + " " + to_string(abs(radius));
  

  return file;
}






#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "iostream"
 
using namespace cv;
using namespace std;
 
int main( )
{
 
    Mat src1;
    src1 = imread("lena.jpg", CV_LOAD_IMAGE_COLOR); 
    namedWindow( "Original image", CV_WINDOW_AUTOSIZE ); 
    imshow( "Original image", src1 ); 
 
    Mat gray;
    cvtColor(src1, gray, CV_BGR2GRAY);
    namedWindow( "Gray image", CV_WINDOW_AUTOSIZE );  
    imshow( "Gray image", gray );
 
    // know the number of channels the image has
    cout<<"original image channels: "<<src1.channels()<<"gray image channels: "<<gray.channels()<<endl; 
 
// ******************* READ the Pixel intensity *********************
    // single channel grey scale image (type 8UC1) and pixel coordinates x=5 and y=2
    // by convention, {row number = y} and {column number = x}
    // intensity.val[0] contains a value from 0 to 255
    Scalar intensity1 = gray.at<uchar>(2, 5);
    cout << "Intensity = " << endl << " " << intensity1.val[0] << endl << endl;
 
    // 3 channel image with BGR color (type 8UC3)
    // the values can be stored in "int" or in "uchar". Here int is used.
    Vec3b intensity2 = src1.at<Vec3b>(10,15);    
    int blue = intensity2.val[0];
    int green = intensity2.val[1];
    int red = intensity2.val[2];
    cout << "Intensity = " << endl << " " << blue << " " << green << " " << red << endl << endl;
 
// ******************* WRITE to Pixel intensity **********************
    // This is an example in OpenCV 2.4.6.0 documentation 
    Mat H(10, 10, CV_64F);
    for(int i = 0; i < H.rows; i++)
        for(int j = 0; j < H.cols; j++)
            H.at<double>(i,j)=1./(i+j+1);
    cout<<H<<endl<<endl;
 
    // Modify the pixels of the BGR image
    for (int i=100; i<src1.rows; i++)
    {
        for (int j=100; j<src1.cols; j++)
        {
                src1.at<Vec3b>(i,j)[0] = 0;
                src1.at<Vec3b>(i,j)[1] = 200;
                src1.at<Vec3b>(i,j)[2] = 0;            
        }
    }
    namedWindow( "Modify pixel", CV_WINDOW_AUTOSIZE );  
    imshow( "Modify pixel", src1 );
 
    waitKey(0);                                         
    return 0;
} 