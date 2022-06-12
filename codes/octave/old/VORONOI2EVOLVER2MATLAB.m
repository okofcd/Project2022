close all;
clear all;
lgaus=100;
filename='evolverGeom.fe';% Evolver file
filename2='"matlabGeom.m"';% matlab file
%% construction d'un réseau avec pour sommets "antiV"
l=10; % "nombre de lignes" : le tissu comportera 2*(l-2)*(l-1) cellules hexagonales
for cpt=1:l,
    for cpt2=1:l,
        antiV(l*cpt+cpt2-l,1)=cpt2;
        antiV(l*cpt+cpt2-l,2)=cpt*sqrt(3)/2*2;
        antiV(l*l+l*cpt-l+cpt2,1)=cpt2+0.5;
        antiV(l*l+l*cpt-l+cpt2,2)=cpt*sqrt(3)/2*2+sqrt(3)/2;
    end
end

%% construction du réseau hexagonal V1=voroin(antiV) + Découpage du tissu
[V1,C]=voronoin(antiV); % V1=vertices C=cells

[vert,junc,cells]=VORONOI2VERTJUNCCELLS(V1,C);

% dans cells, remettre les jonctions dans le bon ordre avec le bon signe pour evolver
for i = 1:length(cells)
    junctions(1)=cells{i}(1);
    vtmp=junc(junctions(1),2); %2e vertex de la 1ere jonction
    for j = 2:length(cells{i})
        for k=1:length(cells{i})
            if junc(cells{i}(k),1)==vtmp && cells{i}(k)~=junctions(j-1)
                junctions(j)=cells{i}(k);
                vtmp=junc(abs(junctions(j)),2);%2em vertex de la jonction trouvée (elle était dans le bon sens)
                break;
            end
            if junc(cells{i}(k),2)==vtmp && cells{i}(k)~=junctions(j-1)
                junctions(j)=-cells{i}(k); %mauvais sens:signe -
                vtmp=junc(abs(junctions(j)),1);%1er vertex de la jonction trouvée (elle était dans le mauvais sens)
                break;
            end
        end
    end
    CELLS{i}=junctions;
    clear junctions
end

%mettre en forme pour evolver en ajoutant une colonne
for i=1:length(CELLS)
    FACES{i}(1)=i;
    for j=2:length(CELLS{i})+1
        FACES{i}(j)=CELLS{i}(j-1);
    end
end
VERTICES(:,1)=1:length(vert);
VERTICES(:,2:3)=vert;
EDGES(:,1)=1:length(junc);
EDGES(:,2:3)=junc;
figure ()
for i=1:length(EDGES)
    plot([VERTICES(EDGES(i,2),2) VERTICES(EDGES(i,3),2)],[VERTICES(EDGES(i,2),3) VERTICES(EDGES(i,3),3)],'r');hold on;
end

for cpt=2:length(FACES{1}),
    if sign(FACES{1}(cpt))==1, e1=2; else, e1=3; end
      XX(cpt-1)=VERTICES(EDGES(abs(FACES{1}(cpt)),e1),2); 
      YY(cpt-1)=VERTICES(EDGES(abs(FACES{1}(cpt)),e1),3);
end
AIRE=polyarea(XX,YY);

%% CONSTRUCTION DU FICHIER EVOLVER
fid = fopen(filename,'wt');
fprintf(fid,'%s \n','STRING   // 1-dimensional "surface"');
fprintf(fid,'%s \n \n','space_dimension 2');

fprintf(fid,'\n \n %s','VERTICES');
for cpt=1:length(VERTICES),
    fprintf(fid,'\n %d %f %f', VERTICES(cpt,:));
end;

fprintf(fid,'\n \n \n %s \n','EDGES');
for cpt=1:length(EDGES),
    fprintf(fid,'\n %d %d %d', EDGES(cpt,:));
    fprintf(fid,'%s ','  tension   ');
    fprintf(fid,'%f', 1+randn/10); 
end;
fprintf(fid,'\n \n \n %s \n','FACES');
for cpt=1:length(FACES),
    FF=FACES{cpt};
    fprintf(fid,'%d \t', FF);
    fprintf(fid,'\n');
    clear FF;
end;

% fprintf(fid,'\n \n \n %s \n','BODIES');
% for cpt=1:length(FACES),
%     fprintf(fid,'\n %d %d %d', cpt , -cpt);
% %     fprintf(fid,'\n %d %d %d', - cpt);
%     fprintf(fid,'%s ','  volume ');
%     fprintf(fid,'%f', AIRE );
% end;

%code equilibrage evolver
fprintf(fid,'\n \n %s %s \n \n','// STUFF TO DO','   // 1-dimensional "surface"');
fprintf(fid,'%s \n \n','read');

fprintf(fid,'\n %s \n \n','set background green;');
fprintf(fid,'%s \n \n','set edges color black;');

fprintf(fid,'%s \n','foreach edge ee where (ee.valence==1) do');
fprintf(fid,'%s \n','	{');
fprintf(fid,'%s \n','		fix ee.vertex[1];');
fprintf(fid,'%s \n','		fix ee.vertex[2];');
fprintf(fid,'%s \n \n','	};');

%fixer les bords
fprintf(fid,'%s \n','foreach vertex vv where (vv.valence==2) do');
fprintf(fid,'%s \n','    {');
fprintf(fid,'%s \n','        fix vv;');
fprintf(fid,'%s \n \n','    };');

fprintf(fid,'%s \n \n','g 100');
fprintf(fid,'%s \n \n','g 100');

%on récupere la géométrie équilibrée pour matlab pour faire de l'inférence
fprintf(fid,'%s \n \n','// PERIODIC DEFORMATION STUFF');
fprintf(fid,'%s %s \n ','str_name:=',filename2);

fprintf(fid,'%s \n','printf "\n \n TENSIONS =[ \n">> str_name;');
fprintf(fid,'%s \n %s \n %s \n %s \n','foreach edge ee do','{','printf "%g \n", ee.tension >> str_name;','};');
fprintf(fid,'%s \n %s \n \n','printf "]; \n" >> str_name;');

fprintf(fid,'%s \n','printf "\n \n VERTICES=[ \n">> str_name;');
fprintf(fid,'%s \n %s \n %s \n %s \n','foreach vertex vv do','{','printf "%g %g %g \n", vv.id, vv.x, vv.y >> str_name;','};');
fprintf(fid,'%s \n \n','printf "]; \n" >> str_name;');

fprintf(fid,'%s \n \n',' printf "\n \n EDGES=[ \n">> str_name; ');			
fprintf(fid,'%s \n %s \n %s \n %s \n %s \n \n','foreach edge ee do ',' { ',' printf "%g %g %g \n", ee.id, ee.vertex[1].id, ee.vertex[2].id >> str_name; ','};','printf "]; \n" >> str_name;'); 
