function [Sigparsed]=SignalExtractdata(data,Start,End1)
Sigparsed=[];
LocShots=[single(Start) single(End1)];
for i=1:size(Start,1)
    for j=1:size(data,2)
       Signal{i,j}=[data(LocShots(i,1):LocShots(i,2),j)];
    end
end
Sigparsed=Signal;
end