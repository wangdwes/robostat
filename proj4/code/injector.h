
#ifndef __INJECTOR_H
#define __INJECTOR_H

#include <random>
#include <gridmap.h>
#include <common.h>

namespace {

  std::vector<Pose> inject(int number, const GridMap& grid_map) 
  {
    std::vector<Pose> particles; 
    static std::default_random_engine generator;
    static std::uniform_real_distribution<> xdis(0, grid_map.global_mapsize_x); 
    static std::uniform_real_distribution<> ydis(0, grid_map.global_mapsize_y); 
    static std::uniform_real_distribution<> thetadis(0, dblpi); 
  
    // generate particles and reject those invalid. 
    double x, y, theta; 
    for (int index = 0; index < number; ++index) { 
      do { x = xdis(generator); y = ydis(generator); }
      while (grid_map.unocc(x, y) < prob_threshold); 
      particles.emplace_back(Pose{x, y, thetadis(generator)}); 
    }

    return particles; 
  }

}

#endif // __INJECTOR_H
