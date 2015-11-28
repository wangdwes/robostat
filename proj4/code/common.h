
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

  double error_lambda = 5e-3; 
  double error_percentage = 0.75; 
  double noise_alpha = 1e-5; 
  double prob_threshold = 0.85; 
  size_t number_sigmas = 24; 
  size_t number_particles = 3000; 

  const double pi = 3.14159265358;
  const double halfpi = pi * 0.5; 
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
