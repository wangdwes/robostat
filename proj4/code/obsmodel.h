
#ifndef __OBSMODEL_H
#define __OBSMODEL_H

#include <vector>
#include <algorithm>
#include <numeric>
#include <cmath>
#include <common.h>
#include <raycaster.h>

namespace {

  const std::vector<double> weigh(const std::vector<Pose>& particles, 
    const LaserScan& laser_scan, RayCaster& caster, double forward_offset = 25) 
  {
    double cumweights = 0, lambda = 5e-3, percentage = 0.75; 
    static std::vector<double> weights; weights.resize(particles.size()); 
    static std::vector<double> errors; errors.resize(caster.nr_sigmas >> 1); 

    // process each particle by comparing with the expected scattered rays.  
    for (int index = 0; index < particles.size(); ++index) {
      Pose particle = particles[index]; 
      double prior = std::max(caster.grid_map->unocc(particle.x, particle.y), 0.0); 
      particle.x += forward_offset * cos(particle.theta); 
      particle.y += forward_offset * sin(particle.theta); 
      const auto scatter = caster.scatter(particle);

      // start at the first available scattered ray and go over the window.
      double theta = modulus(particle.theta - halfpi, dblpi);
      size_t initial = std::distance(caster.offsets.begin(), std::upper_bound(
        caster.offsets.begin(), caster.offsets.end(), theta)) % caster.nr_sigmas;  

      // compute the error between each hit and its corresponding expected value.  
      double angle = modulus(caster.offsets[initial] - theta, dblpi), step = dblpi / caster.nr_sigmas; 
      for (int prog = 0; angle < pi; angle += step, prog++) 
        errors[prog] = std::fabs(laser_scan[static_cast<size_t>(angle * 180 / pi)] - 
          scatter[(initial + prog) % caster.nr_sigmas]); 

      // it is probably a good idea to eliminate the top 25% of the errors
      // due to the dynamic nature of the environment, and measurement range limitation. 
      size_t nth = errors.size() * percentage; 
      std::nth_element(errors.begin(), errors.begin() + nth, errors.end()); 
      double sumerrors = std::accumulate(errors.begin(), errors.begin() + nth, 0); 
      double weight = std::exp(-lambda * sumerrors / nth) * prior; cumweights += weight; 

      weights[index] = weight; 
    }
 
    // normalize and return the weights.    
    std::transform(weights.begin(), weights.end(), weights.begin(), 
      std::bind1st(std::multiplies<double>(), 1.0 / cumweights)); 
    return weights; 
  }

}

#endif // __OBSMODEL_H
