function[NShots1,Location1]=Findshots(rms,WindowSize,Thresholdrms)
NShots1=0;
Location1=[];Lred=[];


    ptemp=(diff(rms));
    for i=1:length(ptemp)
   if (ptemp(i)>=Thresholdrms || ptemp(i)<=-Thresholdrms  );
    Location1=[Location1;i];
      end
    end
   
for i=1:length(Location1)-1
 if Location1(i+1)-Location1(i)<=(0.6*WindowSize) % Localisation
     Lred=[Lred;i+1];
      end
   end
   Location1(Lred) = []; % Remove Adjacent Peaks in Same Window 
NShots1= size(Location1,1);    
end
