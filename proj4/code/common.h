
#ifndef __COMMON_H
#define __COMMON_H

namespace {

  struct Pose
  {
    double x;
    double y;
    double theta;
  };

  typedef Pose Odometry; 
  typedef std::vector<double> LaserScan;

  const double pi = 3.14159265358;
  const double halfpi = pi / 2.0; 
  const double dblpi = pi * 2.0; 

  // like std::fmod, but works on negative numbers. 
  inline double modulus(double numer, double demon) 
  { 
    while (numer < 0) numer += demon; 
    while (numer >= demon) numer -= demon;
    return numer;
  }

  // like modulus, but works on pi only and is
  // guaranteed to return an angle within a symmetric range. 
  inline double truncate(double op) 
  {
    while (op < -pi) op += dblpi; 
    while (op > pi) op -= dblpi; 
    return op; 
  }
}

#endif // __COMMON_H
