
#ifndef __RESAMPLER_H_
#define __RESAMPLER_H_

#include <random>
#include <vector>
#include <common.h>

/* This implements the algorithm as listed in Table 4.4 "low_variance_sampler" from
 * Probabilistic Robotics, Sebastian Thrun, Wolfram Burgard, Bieter Fox, 2006. */

namespace {

  std::vector<Pose>& resample(std::vector<Pose>& particles, const std::vector<double>& weights) 
  {
    // we could have instanitated everything in a class, but nope. 
    static std::vector<Pose> resampled_particles; 
    static std::default_random_engine generator; 
    static std::uniform_real_distribution<double> sampler; 
    resampled_particles.resize(particles.size()); 

    // resample in linear time.  
    double step = 1.0 / static_cast<double>(particles.size()); 
    double remainder = sampler(generator) * step, cumul = weights.front(); 
    for (int spot = 0, index = 0; spot < particles.size(); ++spot, (remainder += step)) {
      while (remainder > cumul) cumul += weights[++index]; 
      if (index == particles.size()) std::cout << "NOPE" << std::endl;
      resampled_particles[spot] = particles[index]; 
    }

    particles.swap(resampled_particles); 
    return particles; 
  }

};

#endif // __RESAMPLER_H_
