function [vert,junc,cells]=voronoiVC2VertJuncCells(V,C)

%voronoiVC2VertJuncCells réordonne les sommets et cellules de voronoi en
%vert junc cells avec les conventions ci-dessous:
% V : coords des sommets de Voronoi (inf inf, x1,y1  x2,y2, ....)
% NB !!! la premiere ligne de V c'est inf, inf.
% C : une cellule de voronoi par point de XY
% chaque cellule contient la liste des indices des points de V la
% constituant). les cellules contenant inf,inf ne sont pas bornées
% vert : liste des coords des vertex (x1,y1  x2,y2, ....)
% junc : liste de couples de vertex constituant des jonctions
% cells : liste d'ensemble de jonctions

%---------------------------------------

% trouver les sommets voisins de chaque sommets de voronoi (leur indice
% dans V)
%cellsV{i}=liste des cellules contenant le sommet d'indice i dans V

Nv=length(V);
Nc=length(C);

for i=2:Nv % pour chaque sommet de voronoi
    compt=1;
    for j=1:Nc %pour chaque cellule
        for k=1:length(C{j}) %si cette cellule contient mon sommet, alors je range le numéro de la cellule dans cellsV{i}
            if C{j}(k)==i
                cellsV{i}(compt)=j;
                compt=compt+1;
            end
        end
    end
end

%mon sommet est dans 3 cellules. pour chaque couple de 2 de ces 3 cellules,
%il y a deux sommets communs, dont le mien. l'autre est un voisin!
%vois{i}:liste des 3 indices dans V des 3 voisins du sommet i
for i=2:Nv
%     if length(cellsV{i})==3 % si le sommet appartient a 3 cells
        [v1,IA,IB] = intersect(C{cellsV{i}(1)},C{cellsV{i}(2)});
        v1(v1==i)=[];
        [v2,IA,IB] = intersect(C{cellsV{i}(1)},C{cellsV{i}(3)});
        v2(v2==i)=[];
        [v3,IA,IB] = intersect(C{cellsV{i}(3)},C{cellsV{i}(2)});
        v3(v3==i)=[];
        vois{i}=[v1,v2,v3];
end

%attention, le 1er vertex de V est infini/infini (point singulier a
%l'infini du diagramme de voronoi.

%3 jonctions par vertex (on en compte en double)
cpt=1;
for i=2:Nv
    junc(cpt,1)=i;
    junc(cpt,2)=vois{i}(1);
    junc(cpt+1,1)=i;
    junc(cpt+1,2)=vois{i}(2);
    junc(cpt+2,1)=i;
    junc(cpt+2,2)=vois{i}(3);
    cpt=cpt+3;
end

%enlever les jonctions reliées au point inf inf
cpt=1;
for i=1:length(junc)
    if ismember(1,junc(i,:))==0 % si la jonction ne contient le point inf inf V(1)
        junc2(cpt,:)=junc(i,:); %je la garde
        cpt=cpt+1;
    end
end
junc=junc2;

%virer les jonctions comptées 2 fois
%d'abord ordonner les V(i,:) pour que l'indice le plus petit soit toujours
%le 1er.
for i=1:length(junc)
    if junc(i,2)<junc(i,1)
        temp=junc(i,1);
        junc(i,1)=junc(i,2);
        junc(i,2)=temp;
    end
end
junc=unique(junc,'rows'); %unication
Nj=length(junc);

%virer de C les cellules non bornées.
cpt=1;
for i=1:length(C)
    if ismember(1,C{i})==0 %si la cellule n'est pas au bord (ne contient pas le vertex 1), alors
        C2{cpt}=C{i}; %je la garde
        cpt=cpt+1;
    end
end
C=C2;
Nc=length(C); % "vrai" nombre de cellules à traiter

%virer le 1er points des vertex (inf,inf)
V(1,:)=[];
Nv=length(V);

%soustraire 1 à tous les indices contenus dans C
for i=1:Nc
    for j=1:length(C{i})
        C{i}(j)=C{i}(j)-1;
    end
end

%soustraire 1 à tous les indices contenus dans junc
for i=1:Nj
    junc(i,1)=junc(i,1)-1;
    junc(i,2)=junc(i,2)-1;
end

%juncV{i}=liste des indices dans junc des jonctions auxquelles le vertex d'indice
% i dans V appartient. length(juncV)=Nv
for i=1:Nv
    cpt=1;
    for j=1:Nj
        if ismember(i,junc(j,:))==1
            juncV{i}(cpt)=j;
            cpt=cpt+1;
        end
    end
end

for i=1:length(C) % pour chaque cellule
    cpt=1;
    for j=1:length(C{i}) % pour chaque vertex de la cellule
        n=length(juncV{C{i}(j)}); %nombre de jonctions auxquelles appartient ce vertex C{i}(j)
        jonctions(cpt:cpt+n-1)=juncV{C{i}(j)}; %lister toutes les jonctions connectées au vertex
        cpt=cpt+n;
    end
    cptt=1;
    for k=1:length(jonctions) % les jonctions apparaissant 2 fois sont dans la cellule, celles n'apparaissant qu'une fois sont juste connectés à la cellule par un vertex donc on les dégage
        if sum(jonctions==jonctions(k))==1 %si 1 seule occurence
            kremove(cptt)=k; % a virer
            cptt=cptt+1;
        end
    end
    jonctions(kremove)=[]; %bye bye
    cells{i}=unique(jonctions);
    clear kremove jonctions
end
vert=V;
end
