
% this function updates the labels by replacing them with the marginal benefits
% in future iterations after picking one particular group of features. since we
% are working with the 'multiple guess' function, if we choose a trajectory whose
% label is one, all trajectories for the associated environment will have zero
% marginal benefits in the future; otherwise the benefits remain unchanged. 

function labels = lblupdate(labels, against) 

  % here we are making some careful selections based on the values of 'against'.  
  % all the labels for those environments will be set to zero if their 
  % corresponding entry in against is also one.  

  [nr_trajs] = numel(labels) / numel(against);  
  [envs, trajs] = meshgrid(find(against), 1: nr_trajs); 
  [labels(sub2ind([nr_trajs, numel(against)], trajs, envs))] = deal(0); 

end


