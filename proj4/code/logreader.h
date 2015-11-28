
#ifndef __LOGREADER_H
#define __LOGREADER_H

#include <string>
#include <fstream>
#include <utility>
#include <memory>
#include <common.h>

namespace {

  struct LogReader
  {

    // A convenience constructor. 
    LogReader(): LogReader(std::string()) {}
    LogReader(const std::string& log_file) {ifs.open(log_file); }

    // read the next entry in the log,
    // may it be odometry or laser scan. 
    std::pair<std::string, std::shared_ptr<void>> next_entry()
    { 
      std::shared_ptr<void> entry; 
      std::string line, type; 

      if (ifs >> type) {
        // read all the data for this particular data entry.  
        std::getline(ifs, line); std::stringstream ss(line); std::vector<double> data; 
        std::copy(std::istream_iterator<double>(ss), std::istream_iterator<double>(), std::back_inserter(data)); 
        // instantiate different datatypes. 
        if (type == "O") entry.reset(new Odometry{data[0], data[1], data[2]});
        if (type == "L") entry.reset(new std::vector<double>(data.begin() + 6, data.end() - 1)); 
      }

      return std::make_pair(type, entry); 
    }

    std::ifstream ifs;

  }; 

}

#endif // __LOGREADER_H
