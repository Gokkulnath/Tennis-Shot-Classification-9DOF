function [PacketLost]= packetloss(sno) % Function to Find the location and number of packet Lost
loc=[]; loss=[];
sno=single(sno); % Serial Number a.k.a packet number 0-255
for i=1:size(sno,2)-1
    if sno(i+1)== sno(i)+1 || (sno(i)== 255 && sno(i+1)== 0)
        loc=[loc];
    else
        loc=[loc; i];
    end
end
for i=1:size(loc,1)
    if sno(loc(i)+1)-sno(loc(i))<= 0
        loss(i)=uint8(255-abs(sno(loc(i)+1)-sno(loc(i))));
    else
        loss(i)=uint8((sno(loc(i)+1)-sno(loc(i))));
    end
end
PacketLost=[loc double(loss')];
end