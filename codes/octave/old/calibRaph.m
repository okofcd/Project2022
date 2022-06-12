% find correspondance between Vx,Vy (galvo tensions text file) and x,y (positions of the bead)
% a executer en se placant direct dans le dossier de calibration

x=[];
y=[];
Vx =[];
Vy =[];

nIm0 = str2double(cell2mat(inputdlg('first image number','First image',1,{'1'})));
nIm1 = str2double(cell2mat(inputdlg('end image number','End image',1,{'1'})));

% tension text file
[fname, ffolder] = uigetfile('.txt', 'select tensions text file');
fna=fname;ffo=ffolder;
% extract tensions from file
[Vxi, Vyi] = getVxVy(ffolder, fname);
    
% calibration images
[fname, ffolder] = uigetfile('.fits', 'select calibration fits', ffolder);
info = fitsinfo([ffolder,fname]);
if (info.PrimaryData.Size(3)<numel(Vxi))
    Vxi = Vxi(end-info.PrimaryData.Size(3)+1:end);
    Vyi = Vyi(end-info.PrimaryData.Size(3)+1:end);
end

% localize bead positions on each images
[xi, yi] = getXYPosRaph(ffolder, fname, nIm0, nIm1);
    
Vxi = Vxi(nIm0:nIm1)';
Vyi = Vyi(nIm0:nIm1)';
x = [x; xi];
y = [y; yi];
Vx = [Vx; Vxi];
Vy = [Vy; Vyi];

ind = find (isnan(x)==0);
x = x(ind);
y = y(ind);
Vx = Vx(ind);
Vy = Vy(ind);

% on cherche une fonction qui passe par nos point
% on pourra faire une meshgrid pour visualiser tout a si on a assez de 
% points

% Interpolate scattered data and find a function to convert tension to pos
fx = TriScatteredInterp(Vx,Vy,x);
fy = TriScatteredInterp(Vx,Vy,y);
% save the converting function
filename = [ffolder, 'convertFct.mat'];
save(filename, 'fx', 'fy');

% Obtain a function to Vx and Vy in function of x and y
fVx = TriScatteredInterp(x,y,Vx);
fVy = TriScatteredInterp(x,y,Vy);
filename = [ffolder, 'convertFctTension.mat'];
save(filename, 'fVx', 'fVy');

% affichage
% figure(1);
% [Xinterp,Yinterp] = meshgrid(-0.4:0.05:0.4,-0.4:0.05:0.4);
% Zinterp = fx(Xinterp,Yinterp);
% contourf(gca,Xinterp,Yinterp,Zinterp)
% pcolor(gca, Xinterp,Yinterp,Zinterp);
% shading(gca,'interp')
% col = colorbar;
% set(get(col,'title'),'String','[x pos]','fontweight','bold')
% set(gca,'tickdir','out','fontweight','bold')
% xlabel('Vx (V)')
% ylabel('Vy (V)')
% title('X position vs tensions')
% box('off')
% shg
% filename = [ffolder, 'XvsTensions.jpg'];
% saveas(gcf, filename, 'jpg');
% 
% figure(2);
% [Xinterp,Yinterp] = meshgrid(-0.4:0.05:0.4,-0.4:0.05:0.4);
% Zinterp = fy(Xinterp,Yinterp);
% contourf(gca,Xinterp,Yinterp,Zinterp)
% pcolor(gca, Xinterp,Yinterp,Zinterp);
% shading(gca,'interp')
% col = colorbar;
% set(get(col,'title'),'String','[y pos]','fontweight','bold')
% set(gca,'tickdir','out','fontweight','bold')
% xlabel('Vx (V)')
% ylabel('Vy (V)')
% title('Y position vs tensions')
% box('off')
% shg
% filename = [ffolder, 'YvsTensions.jpg'];
% saveas(gcf, filename, 'jpg');
% 
% figure(3);
ti = 0:0.5:512;
[qx,qy] = meshgrid(ti,ti);
qzx = fVx(qx,qy);
% mesh(qx,qy,qzx);
% hold on;
% plot3(x,y,Vx,'o');
% hold off
% 
% figure(4);
ti = 0:0.5:512;
[qx,qy] = meshgrid(ti,ti);
qzy = fVy(qx,qy);
% mesh(qx,qy,qzy);
% hold on;
% plot3(x,y,Vy,'o');
% hold off

% save a text file with x, y, Vx, Vy for optical tweezer positionning
% during experiment
f = fopen([ffolder, 'xy_VxVy_bis.txt'], 'a+','n' ); % fichier a copier pour placer le piege  la souris pendant les manips
ind = ~isnan(qzx);
qzx = qzx(ind);
qzy = qzy(ind);
qx = qx(ind);
qy = qy(ind);
for i=1:numel(qx)
    %fprintf(f, '%6.3f %6.3f %5.4f %5.4f\n', x(i), 512-y(i), Vx(i), Vy(i));
    fprintf(f, '%6.3f %6.3f %5.4f %5.4f\n', qx(i), 512-qy(i), qzx(i), qzy(i));
    %fprintf(f, '%6.3f %6.3f %5.4f %5.4f\n', qx(i), qy(i), qzx(i), qzy(i));
end
 fclose(f);
 
% save OT x,y positions
[Vx, Vy] = getVxVy(ffo, fna);
x = fx(Vx', Vy');
y = fy(Vx', Vy');
filename = [ffo, fna(1:end-4), '_positions.txt'];
dlmwrite(filename, [x y], 'delimiter', '\t', 'precision', 6);

% ensuite, on donne la liste des Vx et Vy  derminer, et on calcule les
% valeurs avec les fonctions fx et fy. On rcupre les valeurs dterminer
% dans le fichier texte. On les donne  manger la fonction et c'est bon !
% qx = fx(xi, yi);
% qy = fy(xi,yi);