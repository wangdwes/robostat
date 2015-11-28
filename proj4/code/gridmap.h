
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

  double global_mapsize_x = 1.0;
  double global_mapsize_y = 1.0; 
  double resolution = 1.0;
  double autoshifted_x = 0.0; 
  double autoshifted_y = 0.0; 

  size_t width = 0;
  size_t height = 0; 

  // hide the constructor here so nobody can see. 
  explicit GridMap() {}
  explicit GridMap(const std::string& file_name) { parse(file_name); }

  // makes this object callable so that statement can be simplified. 
  inline double prob (double x, double y) const { 
    int discrete_x = (x - autoshifted_x) / resolution; 
    int discrete_y = (y - autoshifted_y) / resolution; 
    if (discrete_x < 0 || discrete_x >= width ||
        discrete_y < 0 || discrete_y >= height) return 0.0; 
    return std::max(occupancy[discrete_x][discrete_y], 0.0);
  }

  // an utility to parse some map data from a text file. 
  void parse(const std::string& file_name) {

    static std::string token = "global_map[0]";
    static std::unordered_map<std::string, double*> variables = {
      {"robot_specifications->global_mapsize_x", &global_mapsize_x}, 
      {"robot_specifications->global_mapsize_y", &global_mapsize_y}, 
      {"robot_specifications->resolution", &resolution}, 
      {"robot_specifications->autoshifted_x", &autoshifted_x}, 
      {"robot_specifications->autoshifted_y", &autoshifted_y}}; 

    std::string line; 
    std::ifstream ifs(file_name); 
    size_t pos = std::string::npos; 

    if (!ifs.is_open())
      throw std::invalid_argument("Could not open the specified file."); 

    while (true) {

      // read individual lines and break if the preamble has been processed.
      if (!std::getline(ifs, line)) break;
      if ((pos = line.find(token)) != std::string::npos) break; 

      // check if any of the variables has occurred on this line
      for (auto const& pair: variables) {
        size_t pos = line.find(pair.first); 
        if (pos != std::string::npos)
          *pair.second = std::stof(line.substr(pos + pair.first.length() + 1));
      }
    }

    // read in the width and the height of the occupancy grid map, 
    // which are supposed to be immediately adjacent to global_map[0]. 
    std::stringstream ss(line.substr(pos + token.size() + 1)); ss >> width >> height; 
    for (size_t row = 0; row < height; ++row) {
      occupancy.emplace_back(std::vector<double>(width));
      std::getline(ifs, line); std::stringstream ss(line); 
      std::copy(std::istream_iterator<double>(ss), std::istream_iterator<double>(), occupancy.back().begin()); 
    }

  }

private:
  std::vector<std::vector<double>> occupancy; 

};

}

#endif // __GRIDMAP_H_


