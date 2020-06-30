function []= CombinedPlotShot(Sigparsed)
Nfigure=ceil(size(Sigparsed,1)/8);

for i=1:8:size(Sigparsed,1) % Plot the Signals one by one
                  for s=1:8
                if i<=size(Sigparsed,1)
                subplot(2,4,s);
                plot(cell2mat(Sigparsed(i,1)),'r');
                hold on
                plot(cell2mat(Sigparsed(i,2)),'g');
                hold on
                plot(cell2mat(Sigparsed(i,3)),'b');
                hold on
                plot(cell2mat(Sigparsed(i,10)),'cy');
                i=i+1;
                end
            end
        
  figure;
     
end


end
