function Tree (FileName)
% HELP of Classificatory Tree Algorithm.
%
% usage: Tree (filename). Ex: Tree ('database.xls').
% 
% Classify a dataset with classification tree gini's method.
% 
% OUTPUT: 
%           Classificatory Tree (matlab view)
%           Features relative importance ratio list 
%           Classification Cost Graph and Best prune level
%           ROC curves with sensibility and sensitivity. 
%           AUC of the ROCs.
%
% Require:
%           A valid excel file or csv file. 
%           Check for different compatibility with excel file from Linux,
%           Os MAC X, Windows. Try to save with 95/97 compatibility.
%           This file must contain:
%           In the first row the variables names.
%           In the first column the outcome.
%           In the other columns the covariates.
%
% REMARKS:  Do not allow NaNs within features. MatLab algorithm doen't
% catch surrogate splits. NaNs may be a problem for the accuracy of
% classification and is a real problem for the ROC curves. In case with
% features with NaN the ROC may be miss the 100 % value, because NaN is
% outside classification.
% 
% How the program works:
% Table:
%
% leaf (n)      Pleaf(n)   %positive  %sumpositive %negatives %sumnegatives
%
% leaf (n) is the leaf's number.
% Pleaf(n) explanatory percentage of the leaf = within group subject 
%               classified in that leaf / total subject classified (of all groups)
%               classified in that leaf
%
% %positive = positive percentage target. Number of subject of that group
% classified in that leaf / total of subject of that group in the database.
%
% %summpositive =  percentage summ
%
% %negative = negative percentage target. total number of subject in the
% leaf that don't belong to that group / total number of database excluded
% subject that belong to that group
%
% %sumnegatives = percentage sum
%

% 
% Funzionamento del programma:
% Tabella
%
% leaf(n)       Pleaf(n)   %positivi %cumpos  %negativi  %cumneg
%
% leaf(n) = numero della foglia
% Pleaf(n) = percentuale di spiegazione della foglia = percentuale di
% classificati del gruppo in oggetto / totali della foglia inclusi tutti i
% gruppi
% %Positivi = % target di positivi = n? classificati del gruppo in oggetto
% in quella foglia / totale dei soggetti appartenenti al gruppo in oggetto
% nel database.
% %cumpos = cumulativo percentuale = somma cumulativa della % positivi
% %negativi = % target di negativi = n?totale di soggetti all'interno
% della foglia che non appartengono al gruppo in oggetto/totale dei
% soggetti nel database esclusi quelli che appartengono al gruppo in
% oggetto.
% %cumneg = cumulativo dei negativi.
% 
% ATTENZIONE: se i NaN sono nella variabile
%           selezionata dall'algoritmo come classificatore, la ROC
%           mancherà del punto 100% 100% perché qualche caso è uscito dalla
%           classficazione)
% 

%Display Title

fprintf('\nDecision Trees and Predictive Models with cross-validation and\n');
fprintf('ROC (Receiver Operating Characteristic) analysis plot\n');



%% Check for variable consistence

if (nargin ~= 1)
    display('This function need for input a filename (excel or csv file)');
    display('Please, see Help!');

    return;
end

%% UNIX CHECK, Warning for Excel Import

if isunix
    fprintf ('\nRunning under UNIX ... Please check the MATLAB command for excel file import first!');
    fprintf ('\nType: [X, y, textdata] = ExcelImport (FileName) and check X, y, textdata\n\n');
end
%% Import excel of CSV File
% This cell import file from excel format or csv.

global X y textdata t;

%This is necessary because Unix can't load Excel server and give a warning
%message, also if the process goes ok.

warning off all

%Check for file existance
if (fopen(FileName, 'r') == -1)
    fprintf('\nCannot open the file ... \n\n');
    return
end

%Split complete filename in name + extensioni
[File, Extension] = strtok(FileName,'.');

if strcmp(Extension, '.csv') 
    display('CSV file selected');
    [X, y, textdata] = ExcelImport (FileName);
elseif strcmp(Extension, '.xls') 
    display('Excel File selected');
    [X, y, textdata] = ExcelImport (FileName);
elseif strcmp(Extension, '.mat')
    load (FileName);
else
    display('This function need a Excel File or CSV file to perform');
    display('Please type the complete filename, with extension');
    return;
end

%Check the datafile. The number of variables must be the same of the number
%of columns. X contains only variables. Textdata contains also the y name.
if (length (textdata)-1) ~= length (X(1,:))
    display(' ');
    display('Variables name doesnt match with the number of file columns');
    display('Exit...');
end

warning on all

%% Count Variables number
% Count the number of covariates

VarNumber = length (textdata);

fprintf ('%s %d', 'Variables number (number or covariates) : ', VarNumber-1);
display(' ');

clear VarNumber;

%% Launch a GUI to select variables from the imported file

% Launch a GUI for selecting variables to include in analysis
global sSelectedVariables;
global iExit

%Set the global variables SelectedVariables
RocTreeSelVarGUI(textdata);

if iExit== -1
    fprintf ('\nExit requested by the user ...\n');
    return;
end

%Generate an index of selected variables.
IndexOfSelected =0;

for index = 1:1:length(textdata)
    for index2 = 1:1:length(sSelectedVariables)
        if strcmp(sSelectedVariables(1,index2), textdata(1,index))
            %Need index - 1 beause the first variable is the outcome
            %At this moment of the process outcome variable was just
            %converted in the variable y. In the array X (analyzed after by the program)
            %remain all the explanatory variables. So X start from the
            %textdata (2)
            IndexOfSelected (index2) = index -1;
        end
    end
end

%Sort
IndexOfSelected = sort (IndexOfSelected);

%Display Index. Debug only.
%display(IndexOfSelected);

%Cut from textdata all variables not selected

backuptd = textdata;
textdata (:,:) = [];
%textdata (:,:) = [];
textdata(1) = backuptd(1);

for index = 1:1:length(IndexOfSelected)
    textdata(index+1) = backuptd (IndexOfSelected(index)+1);
end

backupX = X;
clear global X;

for index = 1:1:length(IndexOfSelected)
    X(:,index) = backupX (:,IndexOfSelected(index));
end

clear backuptd backupX index index2; 


%% Launch a GUI for select categorical variables
% Launch a GUI for selecting categorical Variables.
global CatSelected;


%Call the GUI
%This GUI create a workspace cell array variable named CatSelected contains
%a list of categorical variables.
RocTreeGUI(textdata) 
%Check the exit status with the global variable iExit
if iExit== -1
    fprintf ('\nExit requested by the user ...\n');
    return;
end

%Control the CatSelected names with textdata (imported from excel) and
%find the corresponding number in the list.
%global gIndexOfCategorical;
gIndexOfCategorical =0;

for index = 1:1:length(textdata)
    for index2 = 1:1:length(CatSelected)
        if strcmp(CatSelected(index2,1), textdata(1,index))
            %Need index - 1 beause the first variable is the outcome
            %At this moment of the process outcome variable was just
            %converted in the variable y. In the array X (analyzed after by the program)
            %remain all the explanatory variables. So X start from the
            %textdata (2)
            gIndexOfCategorical (index2) = index -1;
        end
    end
end

%Sort the index
gIndexOfCategorical = sort (gIndexOfCategorical);

%Display the variables.
display ('Selected variables as categorical :');
for index = 1:1:length(CatSelected)
    display(CatSelected(index));

end

%Cancel on final version. Debug only
%display (gIndexOfCategorical)

%% Check for categorical consistency
% Display a warning if categorical variables are continue
CheckInteger = 0;
if gIndexOfCategorical >= 1
    for i=1:1:gIndexOfCategorical
        %Calculate the remainder of division by one
        Quot = rem(X(:,i), 1);
        %If it isn't empty the variable is not categorical
        if (isempty(find (Quot)) == 0)
            CheckInteger = CheckInteger+ 1;
        end
    end
end

if CheckInteger ~= 0
    fprintf ('\nWARNING: Almost one categorical variables contains float values !!');
    fprintf ('\nNumber of float values = %d\n', CheckInteger);
    fprintf ('\nAre you sure you selected the right variables as categorical ?\n\n');
end
clear CheckInteger;
            


%% Classificatory tree with GINI algorithm
% Classificates and plots tree

%Attenzione: I NaN fanno casino quando appartengono ai classificatori.
%In questo caso, quando i NaN appartengono ai classificatori, la ROC non
%ottiene il valore 100 % finale, perché non li classifica.

fprintf ('\n------ Starting Classificatory tree with Gini algorithm ------\n\n');


%Calculate the number of the groups.
[outcomegroups, numberofgroups] = CalculateOutcomeGroups (y);  

%Perform the classification with or without categorical variables. If you
%have categorical variables you must specify in this function.
%NOTE: don't change these functions without changing the same function in 
%the cross validation paragraph.

if gIndexOfCategorical == 0
    t = classregtree (X, y, 'method', 'classification', 'splitcriterion', 'gdi');
else
    t = classregtree (X, y, 'method', 'classification', 'splitcriterion', 'gdi', 'categorical' ,gIndexOfCategorical);
end

%Display the tree
view(t, 'names', textdata(2:end))

fprintf('\n******************* Analysis of the unpruned tree (maximal tree) **********************\n');

%% Features importance list
% Find feature relative importance  (percentage)

FeaturesImportanceList = CalculateFeaturesImportance (t,textdata);

%% Calculates leafs population

%Return the number of nodes
nnodes = numnodes(t);

%Find the terminal node (the terminal node contain 2 child leafs 
childnodevector = 0;
childnodeindex = 1;

for index=1:1:nnodes
    ischild=children(t,index);
    if (ischild (1) == 0) && (ischild (2) == 0)
        childnodevector(childnodeindex) =  index;
        childnodeindex=childnodeindex+1;
    end
end

%Calculates The Number of leafs
numchildnode = childnodeindex-1;

display(['----> Leafs number (= terminal nodes) : ', int2str(numchildnode)] );

%Close all graph.
close all;

%% Fit the best tree and return pruning level
%Calculate best nodes


%PAY ATTENTION: COMMENT THIS LINE IF THE PROGRAM GIVE YOU AN ERROR. I've
%found that 2009b may give an error in this point. I can't explain why.

Bestprune = BestTree (t,X,y, 10);



%% Plot ROC curves for each group (group 0 is excluded)

%Calculates AUC and plot the Curves of ROC for each group.

%Se ci sono solo 2 gruppi calcola le ROC e l'AUC
%Indica il gruppo. 
%NOTE: Target groups have the following number: 0, 1, 2, ...
%So if your groups are 1,2,3 you will obtain 0, 1, 2

%Specificy the target group from 0 to number of group-1
%Remember that if you have 4 group the variable is 4. But the groups
%are: 0, 1, 2, 3

fprintf('\n\n-------------- Performing ROC curve analysis of the unpruned tree -------------\n');

%Calculate the ROC of each group. 
for index = 1:1:numberofgroups
    [AUC, ROCMatrix] = treeROC (t, index-1, numberofgroups);
end
clear index;

%% Repruning tree following the Breiman et al. guidelines.
% Ask if do you want to prune. In both cases, it calculates the 10 fold
% cross validation and the leave one out cross validation estimated
% classification error. 

%%Continue or stop ?
reply = input('Do you want to prune your tree and analyze it ? Y/N [Y]: ', 's');

if isempty(reply)
    reply = 'Y';
end

%Check if needs to prune or not
if ( (reply == 'y') || (reply == 'Y') )

        fprintf('\n');
        
        %Routine that allow to prune the tree ****************************

        [newt, prunelevel] = reprune (t, numberofgroups, textdata);
        
        %Evaluate the correctly classified patients
        sfit = eval (t, X, prunelevel);

        Convertedy = num2str(y);

        Convertedy = num2str(y);

        pct = mean(strcmp(sfit,Convertedy));

        fprintf ('\nProportion that is correctly classified in the new pruned tree (with resubstitution method): %.2f', pct);


        dtclass = eval(newt,X);
        
        %Compare the y fitted with the y generate from resubstitution
        Convertedy = num2str(y);
        bad = ~strcmp(dtclass,Convertedy);

        dtResubErr = sum(bad) / length(X(:,1));

        fprintf ('\nand therefore the resubstitution error is: %f', dtResubErr);

        %Define the classregtree handling function for the 2 cross validation estimation of the error.
        
        %Test the same function called to built the classification tree,
        %depending on categorical or continue variables.
        %Specify to eval the selected pruned level.
        if gIndexOfCategorical == 0
            dtClassFun = @(xtrain,ytrain,xtest)(eval(classregtree (xtrain, ytrain, 'method', 'classification', 'splitcriterion', 'gdi'),xtest, prunelevel));
        else
            dtClassFun = @(xtrain,ytrain,xtest)(eval(classregtree (xtrain, ytrain, 'method', 'classification', 'splitcriterion', 'gdi','categorical' ,gIndexOfCategorical),xtest, prunelevel));
        end
        
        %The following steps are very time consuming computational
        %analysis. Please wait till matlab will not be in busy status.
        
        %Set the ten fold cross validation stratification.
        cp = cvpartition(y,'k',10); 
     
        fprintf('\n\nReestimating 10 fold cross validation classification error of the new pruned tree.... ');
        %Do the cross validation
        dtCVErr  = crossval('mcr',X,y, ...
                  'predfun', dtClassFun,'partition',cp);

       
        fprintf ('\n10 Fold Cross Validation error: %f', dtCVErr);


        %Set the leave one out cross validation method (LOOCV)
        cp = cvpartition(length(X(:,1)),'leaveout'); % Stratified cross-validation
        
        fprintf('\n\nEstimating classification error with the leave one out cross validation method...');
        %Do the LOOCV        
        dtLOOCVErr  = crossval('mcr',X,y, ...
                  'predfun', dtClassFun, 'partition',cp);

        fprintf ('\nLeave one out Cross Validation (LOOCV) error: %f \n\n', dtLOOCVErr);
else
    
        %Evaluate the correctly classified patients in the maximal tree
        
        fprintf('\n\n-------------- Continuing with the full tree (maximal tree) --------------\n');
        
        sfit = eval (t, X);

        Convertedy = num2str(y);

        Convertedy = num2str(y);

        pct = mean(strcmp(sfit,Convertedy));

        fprintf ('\nProportion that is correctly classified with resubstitution method: %.2f', pct);


        dtclass = eval(t,X);
        %Compare the y fitted with the y with leave one out 
        Convertedy = num2str(y);
        bad = ~strcmp(dtclass,Convertedy);

        dtResubErr = sum(bad) / length(X(:,1));

        fprintf ('\nand therefore the resubstitution error is: %f', dtResubErr);

                
        if gIndexOfCategorical == 0
            dtClassFun = @(xtrain,ytrain,xtest)(eval(classregtree (xtrain, ytrain, 'method', 'classification', 'splitcriterion', 'gdi'),xtest));
        else
            dtClassFun = @(xtrain,ytrain,xtest)(eval(classregtree (xtrain, ytrain, 'method', 'classification', 'splitcriterion', 'gdi','categorical' ,gIndexOfCategorical),xtest));
        end
        
        
        %The following steps are very time consuming computational
        %analysis. Please wait till matlab will not be in busy status.
        
        cp = cvpartition(y,'k',10); % Stratified cross-validation

        fprintf('\n\nReestimating 10 fold cross validation classification error of the new pruned tree.... ');
        %Do the 10 fold cross validation to estimates the error in
        %classification.
        dtCVErr  = crossval('mcr',X,y, ...
                  'predfun', dtClassFun,'partition',cp);

  
        fprintf ('\n10 Fold Cross Validation error: %f', dtCVErr);

        %Set the leave one out cross validation method (LOOCV)
        cp = cvpartition(length(X(:,1)),'leaveout'); % Stratified cross-validation
        
        fprintf('\n\nEstimating classification error with the leave one out cross validation method...');
        %do the LOOCV
        dtLOOCVErr  = crossval('mcr',X,y, ...
                  'predfun', dtClassFun, 'partition',cp);

        fprintf ('\nLeave one out Cross Validation (LOOCV) error: %f \n\n', dtLOOCVErr);

end

%End of Function
end
