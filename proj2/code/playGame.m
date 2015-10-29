
function playGame(game, policies)

  clc;
  close; 

  %% Run the policies on the game
  figure;
  hold on;

  %% be professional and preallocate storage. 
  concat_regrets = zeros(length(policies), game.totalRounds); 
  concat_actions = zeros(length(policies), game.totalRounds); 
  policy_names = cellfun(@class, policies, 'UniformOutput', false); 

  for k = 1: length(policies)
      policy = policies{k};game.resetGame();
      [reward, action, regret] = game.play(policy);
      fprintf('Policy: %s Reward: %.2f\n', class(policy), sum(reward));
      %% save our beloved regrets and actions. 
      concat_regrets(k, :) = regret; 
      concat_actions(k, :) = action; 
  end

  %% awkwardly generate the binary data sequences and plot them. 
  %% note that this works only for binary decisions. 
  [xb, yb] = stairs(1: game.totalRounds, concat_actions' + cumsum(ones(size(concat_actions')) * 2, 2) - 2); 
  [ax, h1, h2] = plotyy(1: game.totalRounds, concat_regrets, xb, yb);

  delete(h2); 

  %% stronger lines. 
  set(h1, 'LineWidth', 2); 

  %% adjust the axe for the actions so we understand what is going on.
  set(ax(2), 'YLim', [0, length(policies) * 2 + 1]); 
  set(ax(2), 'YTick', [0: length(policies) * 2 + 1]); 
  set(ax(2), 'YTickLabel', [{' '}, repmat({'1', '2'}, 1, length(policies))]); 

  %% some labels 
  ylabel(ax(1), 'Regrets');
  ylabel(ax(2), 'Actions Taken'); 

  %% specify the output size. 
  set(gcf, 'PaperPositionMode', 'auto'); 
  set(gcf, 'Position', [100 100 1200 300]); 
   
  grid on; 
  legend([policy_names, policy_names]);

end
