clc
clear all
close all
load TrainMulticlass.mat %% one-against-all Multi class classification model 
%% Preprocessing the Data
labels = unique(TrainMulticlass(:,1));   %# labels: 1/2/3
data = zscore(TrainMulticlass(:,2:end));              %# scale features
numInst = size(TrainMulticlass,1);
numLabels = max(labels);

[N D] = size(TrainMulticlass);
nRows = N; % number of Shots
nTrainSample = 0.7*N; % 70% of samples taken as training

rndIDX = randperm(nRows); % Generate Random indices to perform sampling without replacement

trdata = TrainMulticlass(rndIDX(1:nTrainSample), :); % Train data Separation
trainLabel=trdata(:,1);
data=trdata(:,2:end);

Testdata = TrainMulticlass(rndIDX(nTrainSample:end), :); % Test data Separation
numTest=size(Testdata,1);
testLabel=Testdata(:,1);
testData=Testdata(:,2:end);
 
%% Parameter Tuning
folds = 10;
[C,gamma] = meshgrid(-5:2:15, -15:2:3);
 % # train one-against-all models
model = cell(numLabels,1);
for k=1:numLabels
    % # grid search, and cross-validation
cv_acc = zeros(numel(C),1);
for i=1:numel(C)
    cv_acc(i) = svmtrain(trainLabel, data, ...
                    sprintf('-s 0 -t 2 -c %f -h 0 -g %f -v %d ', 2^C(i), 2^gamma(i), folds));
end
% # pair (C,gamma) with best accuracy
[~,idx] = max(cv_acc);
% # now you can train you model using best_C and best_gamma
best_C = 2^C(idx);
best_gamma = 2^gamma(idx);
    model{k} = svmtrain(double(trainLabel==k), data,...
                    sprintf('-s 0 -t 2 -c %f -g %f -b 1', best_C, best_gamma));
end

%%  get probability estimates of test instances using each model
prob = zeros(numTest,numLabels);
for k=1:numLabels
    [~,~,p] = svmpredict(double(testLabel==k), testData, model{k}, '-b 1');
    prob(:,k) = p(:,model{k}.Label==1);    %# probability of class==k
end

%% predict the class with the highest probability
[~,pred] = max(prob,[],2);
acc = sum(pred == testLabel) ./ numel(testLabel)    % # accuracy
C = confusionmat(testLabel, pred)                   % # confusion matrix