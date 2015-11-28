
#define VISUAL_ENABLED
 
#include <iostream>
#include <string>
#include <chrono>
#include <fstream>
#include <iterator>
#include <random>
#include <memory>
#include <gridmap.h>
#include <raycaster.h>
#include <common.h>
#include <mmodel.h>
#include <obsmodel.h>
#include <resampler.h>
#include <injector.h>
#include <logreader.h>

#ifdef VISUAL_ENABLED
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#endif 

namespace {

  void process(
    const std::string& map_file,
    const std::string& log_file, size_t nr_particles = 3000)
  {
    // instantiate a bunch of stuff, useful or not. 
    GridMap grid(map_file); 
    RayCaster caster(&grid);
    LogReader reader(log_file); 

    // inject a bunch of particles according to some prior uniform distribution.
    auto particles = inject(nr_particles, grid); 

    std::pair<std::string, std::shared_ptr<void>> entry; 
    Odometry prevodom, curodom; bool prevodom_valid = false; int count = 0; 
   
#ifdef VISUAL_ENABLED
    cv::Mat map(grid.height, grid.width, CV_8UC3); 
    // it seems that nested for-loops are the best option at this point.
    for (int row = 0; row < grid.height; ++row) 
      for (int column = 0; column < grid.width; ++column) {
        double intensity = (std::max(0.0, grid.unoccupancy[column][row])) * 255.0; 
        map.at<cv::Vec3b>(row, column) = cv::Vec3b(intensity, intensity, intensity); }
#endif 

    // read each entry, either odometry or laser scan, and process it. 
    while ((entry = reader.next_entry()).second) { ++count;  

      // if the entry is odometry, propagate the particles using the motion model. 
      // note that we need one previous odometry entry in order to compute the difference. 
      if (entry.first == "O") {
        curodom = *std::static_pointer_cast<Odometry>(entry.second);
        if (prevodom_valid) particles = propagate(particles, prevodom, curodom); 
        prevodom = curodom; prevodom_valid = true; 

      // if the entry is laser scan, weigh
      // the particles using the sensor model and resample.
      } else if (entry.first == "L") {
        auto ls = *std::static_pointer_cast<LaserScan>(entry.second); 
        auto weights = weigh(particles, ls, caster); 
        particles = resample(particles, weights); 
      } 

#ifdef VISUAL_ENABLED
      // make a copy of the original map, and plot the particles. 
      cv::Mat frame = map.clone(); 
      for (const auto& particle: particles)
        cv::circle(frame, cv::Point(
          grid.discretizeX(particle.x), 
          grid.discretizeY(particle.y)), 2, cv::Scalar(0, 0, 255));
      // show the map and delay a bit. 
      cv::imshow("Map", frame); 
      cv::waitKey(1);
#endif  

    }
  }
}


int main(int argc, char *argv[])
{
  if (argc < 3) {
    std::cout << "Error: two arguments expected." << std::endl;
    return 0; 
  }

  std::chrono::time_point<std::chrono::system_clock> start, end;
  start = std::chrono::system_clock::now();

  // everything happens right here. 
  process(argv[1], argv[2]); 

  end = std::chrono::system_clock::now();
  std::chrono::duration<double> elapsed_seconds = end-start;
  std::cout << "Time elapsed: " << elapsed_seconds.count() << " seconds." << std::endl;

  return 0;
}
