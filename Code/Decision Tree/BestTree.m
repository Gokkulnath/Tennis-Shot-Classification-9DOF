function BestPrune = BestTree (t, X, y, nsamples)
%% BestTree
% Calculate Best prune level with cross validation method.
% This function return BestPrune level.

   
    fprintf ('\n-------------- Performing cross-validation to calculate the best pruned tree -------------');
    fprintf ('\n\nNumber of v-fold : %d', nsamples);
    %Determina il nodo con il costo minore, ossia il minor splitting tramite il
    %metodo della cross validation
    [c,s,n,best] = test(t,'cross', X, y, 'nsamples', nsamples);

    [mincost,minloc] = min(c);
    
    resubcost = test(t,'resub');
    
         
    %Add a  graph with the comparison of resubstitution and cross
    %validation costs
    figure('Name', 'Cross-validation and Resubstitution error','NumberTitle','off');
    plot(n,c, 'b-o', n, resubcost, 'r--x', n,(mincost+s(minloc))*ones(size(n)),'k--', n(best+1),c(best+1),'bs');
    xlabel('Number of terminal nodes');
    ylabel('Cost (misclassification error)');
    maxy = max (c);
    maxn = max (n);
    minx = min (c)/4;
    axis ([minx maxn 0 maxy]);
    legend('Cross-validation','Resubstitution', '1-SE rule', 'suggested pruning');
   
    hold off;
    
    %return bestprune level
    BestPrune = best;
end