% inference de tensions dans un reseau de cellules
clear all
load EDGES
load TENSIONS
load VERTICES
%% redefinition des vertex, Tensions et junctions (histoire de ne pas ecraser les anciennes valeurs ... peuvent toujours servir)
%jc pour jonction vt pour vertex et T pour TENSIONS
vt=VERTICES;
jc=EDGES;
T=TENSIONS;

%% pour commencer virer les bords les jonctions sur lesquelles il n'y aura pas d'inf�rence

%juncV{i}=liste des indices dans junc des jonctions auxquelles le vertex d'indice
% i dans V appartient. length(juncV)=Nv
cpt1=1;
for i=1:length(vt)%pour chaque vertex on veut savoir les jonctions auxquelles ils appartiennent
    cpt=1;
    for j=1:length(jc)
        if ismember(i,jc(j,2:3))==1
            juncV{i}(cpt)=j;
            cpt=cpt+1;
        end
    end
    % junc2 = elements (listes) dans juncV qui sont composes que de 2 jonctions: ces
    % jonctions contiennent que des vertex appartenant qu'a 2 jonction (ce qui nous interesse c'est des vertex a trois jonctions ou plus)
    if length(juncV{i})<3
        junc2{cpt1}=juncV{i};
        juncV{i}=[];
        vtremove(cpt1)=i;
        cpt1=cpt1+1;
    end
end
figure ();
for i=1:length(vtremove)
    plot(vt(vtremove(i),2),vt(vtremove(i),3),'go');hold on;
end
vt(vtremove,:)=[];
listevt=vt(:,1);
nl=length(listevt);
%extraire les jonctions qui ne sont lies qu'a une seule autre jonction
%res= liste des jonctions a retirer de jc pour faire l'inference

cpt2=1;
for i=1:length(junc2)-1
    for j=i+1:length(junc2)
        if ismember(junc2{i}(1),intersect(junc2{i},junc2{j})) || ismember(junc2{i}(2),intersect(junc2{i},junc2{j}));
            res(cpt2)=intersect(junc2{i},junc2{j});
            cpt2=cpt2+1;
        end
    end
end

jc(res,:)=[];
T(res)=[];

% vt(:,1)=1:length(vt);
for i=1:length(EDGES)
    plot([VERTICES(EDGES(i,2),2) VERTICES(EDGES(i,3),2)],[VERTICES(EDGES(i,2),3) VERTICES(EDGES(i,3),3)],'r');hold on;
end

for i=1:length(jc)
    plot([VERTICES(jc(i,2),2) VERTICES(jc(i,3),2)],[VERTICES(jc(i,2),3) VERTICES(jc(i,3),3)],'g');hold on;
end

% construction matrice
cptt=0;
for i=listevt'
    cptt=cptt+1;
    dd=sqrt((VERTICES(EDGES(juncV{i}(1),3),2)-VERTICES(EDGES(juncV{i}(1),2),2))^2+...
        (VERTICES(EDGES(juncV{i}(1),3),3)-VERTICES(EDGES(juncV{i}(1),2),3))^2);
    
    dx1=VERTICES(EDGES(juncV{i}(1),3),2)-VERTICES(EDGES(juncV{i}(1),2),2);
    dx2=VERTICES(EDGES(juncV{i}(2),3),2)-VERTICES(EDGES(juncV{i}(2),2),2);
    dx3=VERTICES(EDGES(juncV{i}(3),3),2)-VERTICES(EDGES(juncV{i}(3),2),2);
    dy1=VERTICES(EDGES(juncV{i}(1),3),3)-VERTICES(EDGES(juncV{i}(1),2),3);
    dy2=VERTICES(EDGES(juncV{i}(2),3),3)-VERTICES(EDGES(juncV{i}(2),2),3);
    dy3=VERTICES(EDGES(juncV{i}(3),3),3)-VERTICES(EDGES(juncV{i}(3),2),3);
    if dd==0
       M(cptt,juncV{i}(1))=0;
       M(cptt,juncV{i}(2))=0;
       M(cptt,juncV{i}(3))=0;
       
       M(cptt,juncV{i}(1))=0;
       M(cptt,juncV{i}(2))=0;
       M(cptt,juncV{i}(3))=0;
    end
    if EDGES(juncV{i}(1),2)==i
        %projections sur x
        M(cptt,juncV{i}(1))=dx1/dd;
        M(cptt,juncV{i}(2))=(dx2)/dd;
        M(cptt,juncV{i}(3))=(dx3)/dd;
        %projections sur y
        M(cptt+nl,juncV{i}(1))=(dy1)/dd;
        M(cptt+nl,juncV{i}(2))=(dy2)/dd;
        M(cptt+nl,juncV{i}(3))=(dy3)/dd;
    else
        %projections sur x
        M(cptt,juncV{i}(1))=(dx1)/dd;
        M(cptt,juncV{i}(2))=(dx2)/dd;
        M(cptt,juncV{i}(3))=(dx3)/dd;
        %projectins sur y
        M(cptt+nl,juncV{i}(1))=(dy1)/dd;
        M(cptt+nl,juncV{i}(2))=(dy2)/dd;
        M(cptt+nl,juncV{i}(3))=(dy3)/dd;
    end
end
M(2*nl+1,:)=1;

%% Inference

% valeurs propres
% At=M'*M;
% [vept,diagonal]=eig(At);
% [zz,cc]=find(diagonal~=0);
% tinf1=vept(:,cc(1));
% epsl=M*tinf1;


% moindre caree: minimiser || M.X - d ||^2
d=zeros(size(M,1),1);
d(end)=length(jc);

dp=zeros(size(M,1),1);
A=-1*eye(size(M,2),size(M,2));
b=zeros(size(M,2),1);

lb=0*eps*ones(size(M,2),1);
rb=2*ones(size(M,2),1);%+.5*rand(size(M,2),1);

x00=ones(size(M,2),1)+.25*randn(size(M,2),1);
[tinf2,resnorm,residual,exitflag,output,lambda] = minimiseur(M,d,A,b,[],[],[],3000);

%% par la méthode du pseudo - inverse
tinf3=pinv(M)*d;