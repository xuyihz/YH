%% Load ANSYS output
% ANSYS vwrite file
% 
% Xu Yi, 2022.7.12

%%
function YH2_Module_TXT2MAT(oFileName, ANSYS_Mdir, Fext, DATA_FDir)
for i = 1 : length(oFileName)
    % 输出文件的文件名
    o_FN_temp = oFileName(i);
    % 输出文件的路径
    o_FDir_temp = sprintf('%s\\%s.%s', ANSYS_Mdir, o_FN_temp, Fext);
    % 读入输出文件数据
    % load('0.NODE.txt') 自动保存为X0_NODE变量
    % 保存数据至.mat
    DATA_temp = load(o_FDir_temp);
    if i == 1
        load(DATA_FDir, 'NODE');
        NODE = [NODE; DATA_temp];
        save(DATA_FDir, 'NODE', '-append');
    elseif i == 2
        load(DATA_FDir, 'ELEM');
        ELEM = [ELEM; DATA_temp];
        save(DATA_FDir, 'ELEM', '-append');
    end
end
