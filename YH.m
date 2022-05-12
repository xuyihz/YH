%% Generate MGT file
% main M file
% 
% Xu Yi, 2022.5.12

%%
close all; clear; clc;

%% 
fileID = fopen('YH.mgt','w');   % Open or create new file for writing. Discard existing contents, if any.
% addpath(genpath('coor_fun'))    % 搜索路径中加入coor_fun文件夹及其下所有文件夹

%% append initial conditions
YH_init(fileID);

%% append model file
YH_model(fileID);

%%
fprintf(fileID,'*ENDDATA');

%%
fclose('all');
