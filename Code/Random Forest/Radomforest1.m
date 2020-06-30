load train1new.mat
load test1new.mat
train_x=trdata(:,2:end);
train_y=trdata(:,1);
test_x=Testdata(:,2:end);
test_y=Testdata(:,1);
% train_x is nxm matrix where rows are instances and columns are the variables
% train_y is nx1 matrix where each row is the label of the mathing instance
% For other parameters refer to source code
model = train_RF(train_x, train_y,'ntrees', 100,'oobe','y','nsamtosample',25,'method','c','nvartosample',2);
pred = eval_RF(test_x, model, 'oobe', 'y');
accuracy = cal_accuracy(test_y,pred)
