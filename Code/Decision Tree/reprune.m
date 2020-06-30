function [newt, prunelevel] = reprune (t, numberofgroups, textdata)
%HELP of the function reprune
%
% usage: [newt, prunelevel] = reprune (t, numberofgroups, textdata)
% 
% This function ask for the pruning level (U must try and decide before in the
% classification tree tree view) and following give the pruned tree as
% output and calculate the new ROC curves for the pruned tree.
% Note: To select the pruning level, you must check it with the
% classification tree view. In fact, the pruning level is not equal to the
% number of leaf. So you need to check before pruning.
% 
% OUTPUT: 
%           newt : the new pruned tree (in classregtree structure)
%
% Require:
%           t : the previous calculated tree
%           numberofgroups: the number of groups of y
%           textdata: the variable names.


    %Close all graphs
    close all;

    prunelevel = input ('Enter prune level : ');
    fprintf ('\n---- > Pruning with pruning level : %d\n\n', prunelevel);

    newt = prune (t, 'level',prunelevel); 
    view(newt, 'name', textdata(2:end));


    %Return the number of nodes
    nnodes = numnodes(newt);

    %Check how many terminal leafs are present in the tree.
    childnodeindex = 1;

    for index=1:1:nnodes
        ischild=children(newt,index);
        if (ischild (1) == 0) && (ischild (2) == 0)
            childnodeindex=childnodeindex+1;
        end
    end
    
    %numchildnode = number of terminal leafs.
    numchildnode = childnodeindex-1;

    display(['----> Leafs number (= terminal nodes) : ', int2str(numchildnode)] );

    %Calculate and display ROC curves for the new pruned tree.
    fprintf('\n\n-------------- Performing ROC curve analysis of the new pruned tree -------------\n');

    for index = 1:1:numberofgroups
        [AUC, ROCMatrix] = treeROC (newt, index-1, numberofgroups);
    end
   
end
