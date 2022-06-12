function [x,resnorm,residual,exitflag,output,lambda] = minimiseur(C,d,Aineq,bineq,lb,rb,x0,MaxIter_Data)
%% This is an auto generated MATLAB file from Optimization Tool.

##%% Start with the default options
##options = optimoptions('lsqlin');
##%% Modify options setting
##options = optimoptions(options,'Display', 'off');
##options = optimoptions(options,'MaxIter', MaxIter_Data);
##options = optimoptions(options,'Algorithm', 'active-set');
[x,resnorm,residual,exitflag,output,lambda] = lsqlin(C,d,Aineq,bineq,[],[],lb,rb,x0);
