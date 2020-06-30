Code - This File Contains the overall solutin for the problem.Classifer section must be filled with suitable Classfier.

Functions :

[PacketLost]= packetloss(sno) - Function to Find the location and number of packet Lost from packet serial number.
Input-
sno-Double Signal.
Output-
[PacketLost]-PacketLost has both Location at which loss has occured and number of packets that had been lost.


[NShots1,Location1]=Findshots(rms,WindowSize,Thresholdrms) - Function to locate the Shots.
Input-
rms-Double Type Signal 
WindowSize - Integer Constant.
Thresholdrms- Integer Constant.
Output-
[NShots1]- Gives The Number of Shot.
[Location1]-Gives the location of the shot.  

[Sigparsed]=SignalExtractdata(data,Start,End1) This function Extracts the Signal from the data with start and end points passed.
Input-
data- Double Type Signal 
Start,End1- Constant or Interger array
Output-
[Sigparsed]- Cell Containing the Signal parameters (A(x,y,z) G(x,y,z) M(x,y,z) rms) for each shot.

[Features] = FeatureExtract(Sigparsed) This Function  Extract Features from a Signal that is stored in Cell Format.
Input-
Sigparsed - Cell Containing the Signal parameters (A(x,y,z) G(x,y,z) M(x,y,z) rms) for each shot.
Output-
[Features] - Feature Vector. Refer Documentation for more Info.


[ SignalCorrected ] = SignalCorrect( Signal,PacketLost ) - Function that Corrects the Signal to Nullify Packet Loss 

Input-
Signal-Double Type Signal 
PacketLost - Array Containing both Location at which loss has occured and number of packets that had been lost.

Output-
[ SignalCorrected ] -Double Type Signal 