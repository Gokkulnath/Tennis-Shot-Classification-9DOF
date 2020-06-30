%% Final Code
clear all;  clc;

load Clip1.txt; % Load the Corresponding text file
ch = 'x';
nfu = typecast(int8(Clip1),'uint8'); % Replace Clip2 With  Corresponding text file
nfumat = reshape(nfu,[19,length(nfu)/19]);

sno = nfumat(1,:);
[PacketLost]= packetloss(sno);
TotalLoss=sum(PacketLost(:,2))
ax = typecast(uint16(hex2dec([dec2hex(nfumat(3,:)) dec2hex(nfumat(2,:))])),'int16');
ay = typecast(uint16(hex2dec([dec2hex(nfumat(5,:)) dec2hex(nfumat(4,:))])),'int16');
az = typecast(uint16(hex2dec([dec2hex(nfumat(7,:)) dec2hex(nfumat(6,:))])),'int16');

ax = single(ax)/100/9.8;
ay = -single(ay)/100/9.8;
az = single(az)/100/9.8;
rms = sqrt(ay.^2+az.^2);

mx = typecast(uint16(hex2dec([dec2hex(nfumat(9,:)) dec2hex(nfumat(8,:))])),'int16');
my = typecast(uint16(hex2dec([dec2hex(nfumat(11,:)) dec2hex(nfumat(10,:))])),'int16');
mz = typecast(uint16(hex2dec([dec2hex(nfumat(13,:)) dec2hex(nfumat(12,:))])),'int16');

gx = typecast(uint16(hex2dec([dec2hex(nfumat(15,:)) dec2hex(nfumat(14,:))])),'int16');
gy = typecast(uint16(hex2dec([dec2hex(nfumat(17,:)) dec2hex(nfumat(16,:))])),'int16');
gz = typecast(uint16(hex2dec([dec2hex(nfumat(19,:)) dec2hex(nfumat(18,:))])),'int16');

clear nfu nfumat
disp('NFU Data ready!');

time=0:1/100.0:(length(ax)-1)/100.0;
hold on;

%% Signal Correction : Packet Loss Compensated
Signal=[double(ax) double(ay) double(az) double(gx) double(gy) double(gz) double(mx) double(my) double(mz) double(rms)];
[SignalCorrected] = SignalCorrect( Signal,PacketLost);

%% Signal Extraction 
WindowSize=70; %% Can be Any Suitable Value <80 (Impact time always Less than 0.8s)
Thresholdrms=6;
[NShots1,Location1]=Findshots(SignalCorrected(:,10),WindowSize,Thresholdrms);
Start=Location1-40; % 0.8*WindowSize; 40
Ending=Location1+30; % 0.2*WindowSize;  30

[Sigparsed]=SignalExtractdata(SignalCorrected,Start,Ending);

%% Feature Extraction
 Features=[];
[Features] = FeatureExtract(Sigparsed);

if(ch == 'a')
    
    plot(time',ax,'r','linewidth',1); hold on
    plot(time',ay,'g','linewidth',1); hold on
    plot(time',az,'b','linewidth',1); hold on
    plot(time',rms,'cy','linewidth',1);
    figure;
    plot(abs(diff(rms)),'g','linewidth',2);
   
    figure;
    plot(time',Signal(:,1),'r','linewidth',1); hold on
    plot(time',Signal(:,2),'g','linewidth',1); hold on
    plot(time',Signal(:,3),'b','linewidth',1); hold on
    plot(time',Signal(:,10),'cy','linewidth',1);
    
elseif(ch == 'm')
    plot(mx,'c');
    plot(my,'m');
    plot(mz,'y');
    
elseif(ch == 'g')
    plot(gx,'c');
    plot(gy,'m');
    plot(gz,'y');
    
    elseif(ch == 'p')
        % plot all Segmented Shots 
        plotindividual(Sigparsed);
        
end
clear ch