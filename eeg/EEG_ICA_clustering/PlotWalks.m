function PlotWalks(Nodes, Links, FieldName, Format)


nLeaves = size(Links, 1) + 1;

maxField = Nodes(end).(FieldName);
TallyLeaves = zeros(maxField, nLeaves);
TallyGenerations =  TallyLeaves;
 TallyLeavesxGen = nan(nLeaves);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(2, 2, 1)
hold on
for Indx_L = 1:nLeaves
   Node = Indx_L;
   nField = []; 
   nSubordinates = [];
   
   % traverse tree from leaf to root
   while Node <= numel(Nodes)
       
       nField = cat(1, nField, Nodes(Node).(FieldName));
       nSubordinates =  cat(1, nSubordinates, numel(Nodes(Node).Leaves));
       
       Node = Nodes(Node).Parent;
       
   end
    
   plot(nSubordinates, nField, 'Color', [.5 .5 .5])
   
   % tally number of leaves in field for each node
   for Indx_S = 1:numel(nSubordinates)
      nS = nSubordinates(Indx_S);
      nF = nField(Indx_S);
      TallyLeaves(nF, nS) = TallyLeaves(nF, nS)+1;
      
      TallyGenerations(nF, Indx_S) =  TallyGenerations(nF, Indx_S) +1;
      
      TallyLeavesxGen(Indx_L, Indx_S) = nS;
   end
   

    
end

set(gca, 'FontName', Format.FontName)
xlabel('# of subordinates')
ylabel(FieldName)


%%% plot number of sessions covered for nodes with n leaves
% remove values if thereis no node with that n of subordinates
Labels = 1:nLeaves;
Labels(sum(TallyLeaves)==0) = [];
TallyLeaves(:, sum(TallyLeaves)==0) = [];

subplot(2, 2, 2)
bar(TallyLeaves', 'stacked')

Colors = Format.Colormap.Linear(round(linspace(1, 256, maxField+1)), :);
PlotStacks(TallyLeaves', Colors(1:end-1, :))
xticks(1:nLeaves)
xticklabels(Labels)
legend(string(1:maxField))
xlabel('# of subordinates')
ylabel('# of paths')
set(gca, 'FontName', Format.FontName)


%%% plot number of sessions for successive generations
% remove values if thereis no node with that n of subordinates
Labels = 1:nLeaves;
Labels(sum(TallyGenerations)==0) = [];
TallyGenerations(:, sum(TallyGenerations)==0) = [];

subplot(2, 2, 3)
PlotStacks(TallyGenerations', Colors(1:end-1, :))
xticks(1:numel(Labels))
xticklabels(Labels)
legend(string(1:maxField))
xlabel('# of generations')
ylabel('# of paths')


set(gca, 'FontName', Format.FontName)

% plot #of leaves per # of generations (used to see how many is a
% good range of leaves for approximate desired generation level)
subplot(2, 2, 4)
Labels = 1:nLeaves;

Labels(nansum(TallyLeavesxGen)==0) = [];
TallyLeavesxGen(:, nansum(TallyLeavesxGen)==0) = [];

plot(Labels, TallyLeavesxGen, 'Color', [0.5 0.5 0.5 .1],  'LineWidth', 1)
% violin(TallyLeavesxGen)
xticks(1:numel(Labels))
xticklabels(Labels)
xlabel('# generations')
ylabel('# of leaves')


set(gca, 'FontName', Format.FontName)