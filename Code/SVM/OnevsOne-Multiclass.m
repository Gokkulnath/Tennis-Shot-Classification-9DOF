clc
clear all
close all
load TrainMulticlass.mat 
%% Preprocessing the Data
[N D] = size(TrainMulticlass);
nRows = N; % number of Shots
nTrainSample = 0.7*N; % 70% of samples taken as training

rndIDX = randperm(nRows);  % Generate Random indices to perform sampling without replacement

traindata = TrainMulticlass(rndIDX(1:nTrainSample), :); % Train data Separation
labels=traindata(:,1);
data=traindata(:,2:end);

Testdata = TrainMulticlass(rndIDX(nTrainSample:end), :); % Test data Separation
testlabel=Testdata(:,1);
test=Testdata(:,2:end);
 
%% Parameter Tuning
folds = 10;
[C,gamma] = meshgrid(-5:2:15, -15:2:3);

cv_acc = zeros(numel(C),1);
for i=1:numel(C)
    cv_acc(i) = svmtrain(labels, data, ...
                    sprintf('-s 0 -t 2 -c %f -h 0 -g %f -v %d ', 2^C(i), 2^gamma(i), folds));
end

%# pair (C,gamma) with best accuracy
[~,idx] = max(cv_acc);

%# now you can train you model using best_C and best_gamma
best_C = 2^C(idx);
best_gamma = 2^gamma(idx);
%% Trainning  of Final Model
model = svmtrain(labels, data, ...
                    sprintf('-s 0 -t 2 -c %f -g %f -b 1', best_C, best_gamma));
%% Testing of Final Model
[predict_label, accuracy, prob_values] = svmpredict(testlabel, test, model, '-b 0 '); % run the SVM model on the test data
 C = confusionmat(testlabel, predict_label) 