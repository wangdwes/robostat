
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

  // internal data structure for the cache, 
  // and its hasher function. 

  struct DiscreteCoord
  {
    int x, y; 
    DiscreteCoord(): DiscreteCoord(0, 0) {}
    DiscreteCoord(int _x, int _y): x(_x), y(_y) {}

    bool operator==(const DiscreteCoord& other) const 
    { return x == other.x && y == other.y; }
  }; 

  struct DiscreteCoordHasher 
  {
    std::size_t operator()(const DiscreteCoord& coord) const 
    { return std::hash<int>()(coord.x) ^ std::hash<int>()(coord.y); }
  };

  struct RayCaster
  {

    std::vector<double> offsets; 
    std::unordered_map<DiscreteCoord, const std::vector<double>, DiscreteCoordHasher> cache; 

    // a convenience constructor.
    RayCaster(): RayCaster(nullptr) {}  
    RayCaster(GridMap* _grid_map): grid_map(_grid_map) {

      // construct the sampling points. 
      offsets.resize(number_sigmas); 
      std::iota(offsets.begin(), offsets.end(), 0);
      std::transform(offsets.begin(), offsets.end(), offsets.begin(),  
          std::bind1st(std::multiplies<double>(), dblpi / number_sigmas)); 
    }

    // cast the ray originated from the specified pose. 
    // this always returns a distance, valid or invalid. 
    double cast(const Pose& pose)
    {
      double xinc = std::cos(pose.theta) * grid_map->resolution; 
      double yinc = std::sin(pose.theta) * grid_map->resolution; 
      double x = pose.x, y = pose.y;

      while (grid_map->unocc(x, y) > prob_threshold) x += xinc, y += yinc; 
      return std::hypot(x - pose.x, y - pose.y); 
    } 

    // cast the rays at the specified coordinate,
    // but on angles as specified in offsets instead. 
    const std::vector<double>& scatter(const Pose& pose) 
    { 
      DiscreteCoord coord(grid_map->discretizeX(pose.x), grid_map->discretizeY(pose.y)); 
      if (cache.find(coord) == cache.end()) { 
        std::vector<double> distances; 
        for (double offset: offsets) 
          distances.emplace_back(cast({pose.x, pose.y, offset})); 
        cache.emplace(coord, distances); 
      }
      return cache[coord]; 
    }

    // please do not alter this, 
    // otherwise the cache has to be re-built. 
    GridMap *grid_map = nullptr; 

  };

}

#endif // __RAYCASTER_H
