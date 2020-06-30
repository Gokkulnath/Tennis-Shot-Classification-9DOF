function [ SignalCorrected ] = SignalCorrect( Signal,PacketLost ) % Function to Correct the Signal and Nullify Packet Loss
Loc=PacketLost(:,1); % Location of Packet Lost
NumPackets=PacketLost(:,2); % Number of Packets Lost at Corresponding locations
Total=sum(NumPackets);  % Total number of Packets Lost
SignalCorrected=[];
for j=1:size(Signal,2)
    flag=0; % Intitally assume that no packet was lost
    for i=1:size(Signal,1)+Total
        if any(Loc == i)
            idx=find(Loc == i);
            SignalCorrected(i+flag,j)=Signal((i-flag),j);
            SignalCorrected(i+1:i+NumPackets(idx)-1,j)=Signal((i-flag),j);
            flag=flag+NumPackets(idx);
        else
            flag=flag;
            SignalCorrected(i+flag,j)=Signal((i-flag),j);
        end
    end
end
end


