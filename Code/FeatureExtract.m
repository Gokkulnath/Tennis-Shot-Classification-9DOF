function [Features] = FeatureExtract(Sigparsed) % Function to Extract Features
Features=[];
for i=1:size(Sigparsed,1)
    Meanax=mean(cell2mat(Sigparsed(i,1))); Meangx=mean(cell2mat(Sigparsed(i,4))); % Mean Acceleration and Gyroscope data
    Meanay=mean(cell2mat(Sigparsed(i,2))); Meangy=mean(cell2mat(Sigparsed(i,5)));
    Meanaz=mean(cell2mat(Sigparsed(i,3))); Meangz=mean(cell2mat(Sigparsed(i,6)));
    Sigax=range(cell2mat(Sigparsed(i,1))); Siggx=range(cell2mat(Sigparsed(i,4)));% Variance Acceleration and Gyroscope data
    Sigay=range(cell2mat(Sigparsed(i,2))); Siggy=range(cell2mat(Sigparsed(i,5)));
    Sigaz=range(cell2mat(Sigparsed(i,3))); Siggz=range(cell2mat(Sigparsed(i,6)));
    ax=cell2mat(Sigparsed(i,1)); ay= cell2mat(Sigparsed(i,2)); az=cell2mat(Sigparsed(i,3));
    gx=cell2mat(Sigparsed(i,4)); gy= cell2mat(Sigparsed(i,5)); gz=cell2mat(Sigparsed(i,6));
    rmstmp=cell2mat(Sigparsed(i,10));
    Peak=max(rmstmp);
    ind = find(rmstmp==Peak);
    loc=max(ind);  % Location of Peak (Impact Point)
    Features=[Features; Meanax Meanay Meanaz Sigax Sigay Sigaz min(ax) min(ay) min(az) ax(loc,1) ay(loc,1) az(loc,1) Meangx Meangy Meangz Siggx Siggy Siggz min(gx) min(gy) min(gz) gx(loc,1) gy(loc,1) gz(loc,1)];
end
end

