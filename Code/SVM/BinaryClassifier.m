 clc
 %clear all
%close all

 %load Traindata.mat

% labels=Traindata(:,1);
% data=Traindata(:,2:end);
[N D] = size(Traindata);

nRows = N; % number of rows
nTrainSample = 0.85*N; % number of samples

rndIDX = randperm(nRows); 

trdata = Traindata(rndIDX(1:nTrainSample), :); 
labels=trdata(:,1);
 data=trdata(:,2:end);

Testdata = Traindata(rndIDX(nTrainSample:end), :); 

  testlabel=Testdata(:,1);
 test=Testdata(:,2:end);


%Scaling of Data 
vec = data(:,:);

%# get max and min
maxVec = max(vec);
minVec = min(vec);

%# normalize to -1...1
for i=1:nTrainSample
vecN(i,:)=((vec(i,:)-minVec)./(maxVec-minVec) - 0.5 ) *2;


%# to "de-normalize", apply the calculations in reverse
%denormalizedata(i,:) = (vecN(i,:)./2+0.5).* (maxVec-minVec) + minVec
end
folds = 10;
[C,gamma] = meshgrid(-5:2:15, -15:2:3);

%# grid search, and cross-validation
cv_acc = zeros(numel(C),1);
for i=1:numel(C)
    cv_acc(i) = svmtrain(labels, data, ...
                    sprintf('-s 0 -t 2 -c %f -h 0 -g %f -v %d ', 2^C(i), 2^gamma(i), folds));
end

%# pair (C,gamma) with best accuracy
[~,idx] = max(cv_acc);

%# contour plot of paramter selection
contour(C, gamma, reshape(cv_acc,size(C))), colorbar
hold on
plot(C(idx), gamma(idx), 'rx')
text(C(idx), gamma(idx), sprintf('Acc = %.2f %%',cv_acc(idx)), ...
    'HorizontalAlign','left', 'VerticalAlign','top')
hold off
xlabel('log_2(C)'), ylabel('log_2(\gamma)'), title('Cross-Validation Accuracy')

%# now you can train you model using best_C and best_gamma
best_C = 2^C(idx);
best_gamma = 2^gamma(idx);


model = svmtrain(labels, data, ...
                    sprintf('-s 0 -t 2 -c %f -g %f -b 0', best_C, best_gamma));
          
 [predict_label, accuracy, prob_values] = svmpredict(testlabel, test, model, '-b 0 '); % run the SVM model on the test data
 C = confusionmat(testlabel, predict_label) 
% accuracy
% best_C
