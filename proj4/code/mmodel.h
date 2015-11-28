
#ifndef __MMODEL_H
#define __MMODEL_H

#include <cmath>
#include <random>
#include <vector>
#include <common.h>

/* This implements the algorithm as listed in Table 5.6 "sample_motion_model_odometry" from
 * Probabilistic Robotics, Sebastian Thrun, Wolfram Burgard, Bieter Fox, 2006. */

namespace {

  std::vector<Pose>& propagate(std::vector<Pose>& particles, const Odometry& prev, const Odometry& cur) 
  {
    double delta_rot1 = truncate(std::atan2(cur.y - prev.y, cur.x - prev.x) - prev.theta); 
    double delta_trans = std::hypot(cur.y - prev.y, cur.x - prev.x); 
    double delta_rot2 = truncate(cur.theta - prev.theta - delta_rot1); 

    static double alpha1 = 3, alpha2 = 3, alpha3 = 3, alpha4 = 3; 
    static std::normal_distribution<double> sampler;
    static std::default_random_engine generator; 

    double hatdelta_rot1 = delta_rot1 - sampler(generator) *
      std::sqrt(alpha1 * delta_rot1 * delta_rot1 + alpha2 * delta_trans * delta_trans); 
    double hatdelta_trans = delta_trans - sampler(generator) * 
      std::sqrt(alpha3 * delta_trans * delta_trans + alpha4 * (delta_rot1 * delta_rot1 + delta_rot2 * delta_rot2)); 
    double hatdelta_rot2 = delta_rot2 - sampler(generator) * 
      std::sqrt(alpha1 * delta_rot2 * delta_rot2 + alpha2 * delta_trans * delta_trans); 

    for (auto& particle: particles) {
      particle.x += hatdelta_trans * std::cos(particle.theta + hatdelta_rot1); 
      particle.y += hatdelta_trans * std::sin(particle.theta + hatdelta_rot1); 
      particle.theta = modulus(particle.theta + hatdelta_rot1 + hatdelta_rot2, dblpi); 
    }

    return particles; 
  }

}

#endif
