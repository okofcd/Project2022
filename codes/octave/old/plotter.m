% plot network with color code

function [pl]=PLOTTER(vrt,jnc,tens,tit)
%figure ()
set(gcf,'color','w');
couleur=jet(102);
tmax=max(tens);
tmin=min(tens);
deltaT=tmax-tmin;
for i=1:length(jnc)
   % pl=plot([vrt(jnc(i,1),1),vrt(jnc(i,2),1)],[vrt(jnc(i,1),2),vrt(jnc(i,2),2)]);hold on;
    pl=plot([vrt(jnc(i,2),2),vrt(jnc(i,3),2)],[vrt(jnc(i,2),3),vrt(jnc(i,3),3)],'color',[couleur(round(1+100*(tens(i)-tmin)/deltaT),1),couleur(round(1+100*(tens(i)-tmin)/deltaT),2),couleur(round(1+100*(tens(i)-tmin)/deltaT),3)],'linewidth',1.5);hold on;
end
title(tit);
axis equal