%% Load ANSYS output
% ANSYS vwrite file
% 
% Xu Yi, 2022.7.12

%%
function YH2_Module_TXT2MAT(oFileName, ANSYS_Mdir, Fext, DATA_FDir)

%%
for i = 1 : length(oFileName)
    % 输出文件的文件名
    o_FN_temp = oFileName(i);
    % 输出文件的路径
    o_FDir_temp = sprintf('%s\\%s.%s', ANSYS_Mdir, o_FN_temp, Fext);
    % 读入输出文件数据
    % load('0.NODE.txt') 自动保存为X0_NODE变量
    load(o_FDir_temp);
    % 数据保存的变量名
    DATA_N_temp = replace(o_FN_temp, '.', '_');
    DATA_N_temp = strcat('X', DATA_N_temp);
    % 保存数据至.mat
    save(DATA_FDir, DATA_N_temp, '-append');
end
