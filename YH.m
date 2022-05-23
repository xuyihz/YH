%% Generate MGT file
% main M file
% 
% Xu Yi, 2022.5.12

%%
close all; clear; clc;

%% 
fileID = fopen('YH.mgt','w');   % Open or create new file for writing. Discard existing contents, if any.
addpath(genpath('Func'))        % 搜索路径中加入Func文件夹及其下所有文件夹
MatFile = true;                % 记录 true / false

%% append initial conditions
YH_init(fileID);

%% append model file
YH_model(fileID, MatFile);

%%
fprintf(fileID,'*ENDDATA');

%%
fclose('all');
