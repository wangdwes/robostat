
#ifndef __GRIDMAP_H
#define __GRIDMAP_H

#include <vector>
#include <cmath>
#include <fstream>
#include <exception>
#include <unordered_map>
#include <sstream>
#include <iterator>

namespace {

  struct GridMap 
  {
    double global_mapsize_x = 1.0;  // centimeter
    double global_mapsize_y = 1.0;  // centimeter
    double resolution = 1.0;        // centimeter per pixel
    double autoshifted_x = 0.0;     // centimeter
    double autoshifted_y = 0.0;     // centimeter 
    size_t width = 0;               // pixel
    size_t height = 0;              // pixel

    // a convenience constructor for reading in the laser scan directly. 
    explicit GridMap(): GridMap(std::string()) {}
    explicit GridMap(const std::string& file) { parse(file); }

    inline int discretizeX(double x) const { return (x - autoshifted_x) / resolution; }
    inline int discretizeY(double y) const { return (y - autoshifted_y) / resolution; } 

    // returns the unoccupancy probability. 
    // negative result indicates invalid grid cell. 
    inline double unocc (double x, double y) const { 
      int discrete_x = discretizeX(x), discrete_y = discretizeY(y); 
      if (discrete_x < 0 || discrete_y < 0 || discrete_x >= width || discrete_y >= height) return -1; 
      return unoccupancy[discrete_x][discrete_y]; 
    }

    bool parse(const std::string& file) 
    {
      static std::string preface = "global_map[0]"; 
      static std::unordered_map<std::string, double*> variables = { 
        {"robot_specifications->global_mapsize_x", &global_mapsize_x}, 
        {"robot_specifications->global_mapsize_y", &global_mapsize_y}, 
        {"robot_specifications->resolution", &resolution}, 
        {"robot_specifications->autoshifted_x", &autoshifted_x}, 
        {"robot_specifications->autoshifted_y", &autoshifted_y}}; 

      std::ifstream ifs(file);
      if (!ifs.is_open()) {
        std::cerr << "Unable to open the map file." << std::endl;
        return false;
      }

      // read the preamble, which can be a collection of
      // name-value pairs, as specified in the 'variables' map.  
      std::string line; size_t pos = std::string::npos; 
      while (std::getline(ifs, line)) { 
        if ((pos = line.find(preface)) != std::string::npos) break; 
        for (const auto& pair: variables)
          if ((pos = line.find(pair.first)) != std::string::npos) 
            *pair.second = std::stof(line.substr(pos + pair.first.length() + 1)); 
      }

      // at this point we are expecting the one and only map 
      // stored in this file. read in the width and height and the entire map. 
      std::stringstream ss(line.substr(pos + preface.size() + 1)); ss >> width >> height; 
      for (size_t column = 0; column < width; ++column) {
        unoccupancy.emplace_back(std::vector<double>(height)); 
        std::getline(ifs, line); std::stringstream ss(line); 
        std::copy(std::istream_iterator<double>(ss), std::istream_iterator<double>(), unoccupancy.back().begin()); 
      }

      return true; 
    }

    // made publicly available for ease of access.
    std::vector<std::vector<double>> unoccupancy; 

  };

}

#endif // __GRIDMAP_H_


