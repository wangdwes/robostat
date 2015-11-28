  
#include <iostream>
#include <string>
#include <chrono>
#include <fstream>
#include <iterator>
#include <random>
#include <gridmap.h>
#include <raycaster.h>
#include <common.h>
#include <mmodel.h>
#include <obsmodel.h>
#include <resampler.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>

namespace {

  void process(const std::string& map_file, const std::string log_file)
  {

    GridMap grid_map(map_file); 
    RayCaster caster(&grid_map);
  
    const double threshold = 0.8; 
    const size_t nr_particles = 3000; 

    std::ifstream ifs(log_file); 
    if (!ifs.is_open()) 
      throw std::invalid_argument("Unable to open the specified file."); 
 
    std::vector<Pose> particles;  
    std::default_random_engine generator;
    std::uniform_real_distribution<> xdis(0, grid_map.global_mapsize_x); 
    std::uniform_real_distribution<> ydis(0, grid_map.global_mapsize_y); 
    std::uniform_real_distribution<> thetadis(0, dblpi); 

    double x, y, theta; 
    for (int index = 0; index < nr_particles; ++index) {
      do {
        x = xdis(generator);
        y = ydis(generator); 
      } while (grid_map.prob(x, y) < threshold); 

      theta = thetadis(generator); 
      particles.push_back({x, y, theta});
    }
    
    cv::Mat image = cv::imread("wean.jpg"); 

    std::string type, line; 
    std::vector<double> data; 

    int index = 0; 
    Odometry prev, cur;
    bool prev_valid = false;

    while (ifs >> type) {
      std::getline(ifs, line);
      std::stringstream ss(line); 
      std::vector<double> data; 
      std::copy(std::istream_iterator<double>(ss), std::istream_iterator<double>(), std::back_inserter(data)); 

      if (type == "O") {

        cur = {data[0], data[1], data[2]}; 
        if (prev_valid)
          particles = propagate(particles, prev, cur);
        prev = cur; prev_valid = true; 

      } else if (type == "L") {

        Pose center = {data[0], data[1], data[2]}; 
        Pose laser = {data[3], data[4], data[5]}; 
        std::vector<Pose> new_particles(particles); 

        for (auto& particle: new_particles) {
          double dist = std::hypot(laser.x - center.x, laser.y - center.y); 
          particle.x += dist * std::cos(particle.theta);
          particle.y += dist * std::sin(particle.theta); 
        }

        LaserScan ls = std::vector<double>(data.begin() + 6, data.end() - 1);
        auto weights = weigh(new_particles, ls, caster);

        for (int index = 0; index < particles.size(); index++) {
          std::cout << particles[index].x << "; " << particles[index].y << "; " << 
            grid_map.prob(particles[index].x, particles[index].y) << std::endl;
          if (grid_map.prob(particles[index].x, particles[index].y) < threshold)
            weights[index] = 0; 
        }
            
        particles = resample(new_particles, weights);

      }

      cv::Mat frame = image.clone(); 
      for (const auto& particle: particles) {
        std::cout << particle.x << "; " << particle.y << std::endl;
        cv::circle(frame, cv::Point(
          (particle.x - grid_map.autoshifted_x) / grid_map.resolution, grid_map.height - 1 - 
          (particle.y - grid_map.autoshifted_y) / grid_map.resolution), 1, cv::Scalar(0, 0, 255));
      }

      cv::imshow("Wean Hall", frame); 
      cv::waitKey(0); 

      std::cout << (++index) << std::endl;

    }
  }
}


int main(int argc, char *argv[])
{
  if (argc < 3) {
    std::cout << "Error: two arguments expected." << std::endl;
    return 0; 
  }

  process(argv[1], argv[2]); 

  return 0;
}
