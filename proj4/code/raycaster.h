
#ifndef __RAYCASTER_H
#define __RAYCASTER_H

#include <vector>
#include <limits>
#include <functional>
#include <algorithm>
#include <cmath>
#include <numeric>
#include <iostream>
#include <iterator>
#include <common.h>
#include <gridmap.h>

namespace {

// internal data structure for the cache. 
struct DiscretePosition
{
  int x;
  int y;

  DiscretePosition() {}
  DiscretePosition(int _x, int _y): x(_x), y(_y) {}
  
  bool operator==(const DiscretePosition& other) const 
  { return x == other.x && y == other.y; }
};

// hasher for the data structure as declared above. 
struct DiscretePositionHasher
{
  std::size_t operator()(const DiscretePosition& pos) const 
  { return std::hash<int>()(pos.x) ^ std::hash<int>()(pos.y); }
}; 

struct RayCaster 
{
  double threshold = 0.20; 
  size_t nr_sigmas = 40; 

  std::vector<double> offsets; 
  std::unordered_map<DiscretePosition, std::vector<double>, DiscretePositionHasher> cache; 

  // a convenience constructor. 
  RayCaster(): RayCaster(nullptr) {}
  RayCaster(GridMap* _grid_map): grid_map(_grid_map) {
    // populate the sigma points. 
    offsets.resize(nr_sigmas); 
    std::iota(offsets.begin(), offsets.end(), 0); 
    std::transform(offsets.begin(), offsets.end(), offsets.begin(),
      [=](double d) { return d * dblpi / nr_sigmas; }); 
  }
 
  // cast the ray originated from the specified pose. 
  // this either returns the distance or infinity. 
  double cast(const Pose& pose) 
  {
    double horzinc = std::cos(pose.theta) * grid_map->resolution; 
    double vertinc = std::sin(pose.theta) * grid_map->resolution; 
    double x = pose.x, y = pose.y;
    double distance = std::numeric_limits<double>::infinity();

    while (true) {

      // if the probability is reasonable, this is considered as a hit.       
      double prob = grid_map->prob(x, y); 
      if (prob <= threshold) { 
        distance = std::hypot(x - pose.x, y - pose.y); break; 
      }

      x += horzinc;
      y += vertinc;
    }

    return distance; 
  }

  // cast the rays at the specified position, but instead on
  // angles as specified in offsets
  const std::vector<double>& scatter(const Pose& pose)
  {
    int discrete_x = (pose.x - grid_map->autoshifted_x) / grid_map->resolution; 
    int discrete_y = (pose.y - grid_map->autoshifted_y) / grid_map->resolution;  
  
    // if this position has never been queried, ...
    DiscretePosition pos(discrete_x, discrete_y);
    if (cache.find(pos) == cache.end()) {
      std::vector<double> distances; 
      for (double offset: offsets)  
        distances.emplace_back(cast({pose.x, pose.y, offset})); 
      cache.emplace(pos, distances); 
    }
 
    return cache[pos]; 
  } 

  // please do not alter this, 
  // otherwise the cache has to be re-built. 
  GridMap *grid_map = nullptr; 

};

}

#endif // __RAYCASTER_H
