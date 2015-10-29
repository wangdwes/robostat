
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

  c1 = cumsum((concat_actions == 1));
  c2 = cumsum((concat_actions == 2));

  ucb = [0.2 + sqrt(log(c1+c2)./(2*(c1))),
  0.8 + sqrt(log(c1+c2)./(2*(c2)))]

  %% awkwardly generate the binary data sequences and plot them. 
  %% note that this works only for binary decisions. 
%%  [xb, yb] = stairs(1: game.totalRounds, concat_actions' + cumsum(ones(size(concat_actions')) * 2, 2) - 2); 
  [ax, h1, h2] = plotyy(1: game.totalRounds, concat_regrets, 1: game.totalRounds, ucb);

  %% stronger lines. 
  set(h1, 'LineWidth', 2); 
  set(h2, 'LineWidth', 2); 

  %% some labels 
  ylabel(ax(1), 'Regrets');
  ylabel(ax(2), 'Upper Confidence Bound'); 

  %% specify the output size. 
  set(gcf, 'PaperPositionMode', 'auto'); 
  set(gcf, 'Position', [100 100 1200 300]); 
   
  grid on; 
  legend([policy_names, {'UCB for Action 1', 'UCB for Action 2'}]);

end
