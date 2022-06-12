%%                 --
%          FORCE  INFERENCE  
% Inference of force assuming mechanical equilibrium and uniform preassure
% The problem can be sum in solving the following optimization problem
%                  --
%%
clear ; close all; clc
matlabGeom5; %matlab file containing a tissu geometrical data
T=TENSIONS; %list of known tension values : used only for validation (when comparing known tensions and infered one)
VT=VERTICES; %vertices coordinate
JC=EDGES; %connectivity between vertices

figure (1);
for i=1:length(EDGES)
    plot([VERTICES(EDGES(i,2),2) VERTICES(EDGES(i,3),2)],[VERTICES(EDGES(i,2),3) VERTICES(EDGES(i,3),3)],'r');hold on;
end

%remove vertices which don't appear in edges 
ct=1;
ctr=1;
cpt0=1;
cp=1;
VERTICESREMOVE=[];
for i=1:size(VERTICES,1)
  a = i==EDGES(:,2:3);
  if sum(sum(a))>0
    VTn(ct,:)=VERTICES(i,:);
    ct=ct+1;
  else
    VTr(ctr)=i;
    ctr=ctr+1;
  endif
end
%listing junctions owning the same vertex >> junc
junc={};
for t=1:size(VTn,1)
  q = t==JC(:,2:3);
  [i, j] = find(q==1);
  junc{t} = [t; JC(i,1)];
end
%selection of vertices with more than 2 junctions linked (3, 4 ...)
ct1=1;
ctr1=1;
juncf = {};
juncr = {};
for i=1:length(junc)
    if length(junc{i}(2:end))>=3 %selection of vertex which have 2 junctions linked
        juncf{ct1}=junc{i}(:);
        ct1=ct1+1;
      else
        juncr{ctr1}=junc{i}(:);
        ctr1=ctr1+1;
    end
end
%JC(juncr,:)=[];

figure(2);
for i=1:length(JC)
    plot([VTn(JC(i,2),2) VTn(JC(i,3),2)],[VTn(JC(i,2),3) VTn(JC(i,3),3)],'k');hold on;
end

##vtrm=[VERTICESREMOVE vtremove];
##VT(vtrm,:)=[];%list of vertices that have effectivelly 3 or more junctions linked and that belong to the edges list
##nv=size(VT,1);
##
## not very necessary but !!!
##remake list of edges considering only vertices with more than 2 junctions linked
##cptr5=1;
##res=[];
##for i=1:length(juncV2)-1
##    for j=i+1:length(juncV2)
##        if ismember(juncV2{i}(1),intersect(juncV2{i},juncV2{j})) || ismember(juncV2{i}(2),intersect(juncV2{i},juncV2{j}))
##            res(cptr5)=intersect(juncV2{i},juncV2{j});
##            cptr5=cptr5+1;
##        end
##    end
##end
##JC(res,:)=[];
##T(res)=[];
##
%plot of cell network

##axis equal;
##
## back now !!!
##
## construction of the matrix
##listevt=VT(:,1)';
##cpt4=0;
##M=zeros(2*nv,length(JC));
##for i=listevt
##    cpt4=cpt4+1;
##    if ismember(i,EDGES(:,2:3))==0
##        M(cpt4,:)=0;
##        M(cpt4+nl,ind1)=0;
##    else
##        for k=1:length(juncV{i})
##            deltax=VERTICES(EDGES(juncV{i}(k),3),2)-VERTICES(EDGES(juncV{i}(k),2),2);%Xi+1 - Xi
##            deltay=VERTICES(EDGES(juncV{i}(k),3),3)-VERTICES(EDGES(juncV{i}(k),2),3);%Yi+1 - Yi
##            normJunction=sqrt(deltax^2+deltay^2);
##            [ind1 ind2]=find(JC(:,1)==juncV{i}(k));%find the corresponding junction
##            
##            if normJunction==0%take in account very small distance
##                normJunction=eps*1e9;
##            end
##            
##            if EDGES(juncV{i}(k),2)==i
##                M(cpt4,ind1)=deltax/normJunction;
##                M(cpt4+nv,ind1)=deltay/normJunction;
##            else
##                M(cpt4,ind1)=-deltax/normJunction;
##                M(cpt4+nv,ind1)=-deltay/normJunction;
##            end
##        end
##    end
##end
##we add one last equation in order to take in account the normalization
##condition
##MM=zeros(2*nv+1,size(M,2));
##MM(1:2*nv,:)=M;
##MM(2*nv+1,:)=1;
##
##removing the zero lines in the matrix : remove line which have only zeros
##for i=1:size(M,1)
##    if MM(i,:)==0
##        M(i,:)=[];
##    end
##end
##
## Computing infered tensions
##
## with least square methods : minimizing || M.X - d ||^2  >> with lsqlin solver in optimization toolbox
##d=zeros(size(MM,1),1);
##d(end)=length(JC);
##A=-1*eye(size(MM,2),size(MM,2));
##b=zeros(size(MM,2),1);
##x00=ones(size(MM,2),1);
##[tinf2,resnorm,residual,exitflag,output,lambda] = minimiseur(MM,d,A,b,[],[],x00,3000);
##
##the infered tensins can also be compute with moore - penrose pseudoinverse method
##tinf3=pinv(MM)*d;
##
## figures 
##figure ()
##subplot(121)
##tt='Vraies valeurs';
##PLOTTER(VERTICES,JC,T,tt);% PLOTTER = function that plot with color code
##axis off;
##subplot(122)
##ff='Avec le solveur lsqlin';
##PLOTTER(VERTICES,JC,tinf2,ff);
##axis off;
##figure ()
##xx=linspace(min(min(tinf2),min(T)),max(max(tinf2),max(T)),length(tinf2));
##scatter(T,tinf2,5,'filled','r');hold on;% infered values vs true tensions
##plot(xx,xx,'k-','linewidth',2);
##xlabel('true values');