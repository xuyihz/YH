%% Run ANSYS in batch mode
% Mechanical APDL Product Launcher
% Simulation Environment: ANSYS Batch
% Tools - Display Command Line
% Xu Yi, 2022.5.26

%%
function status = YH_Module_RunANSYS(ANSYS_JName, ANSYS_Mdir, ANSYS_iFdir, ANSYS_oFdir)
% 自动调用ANSYS
ANSYS_dir = "C:\Program Files\ANSYS Inc\v202\ansys\bin\winx64\MAPDL.exe";

% -b: batch模式; -p: license; -dir: 工作目录; -i: 输入文件; -o: 输出文件
% 网上搜到：堆栈内存被名为KMP_STACKSIZE的环境变量默认指定为512k，不足以调用ANSYS。增加SET KMP_STACKSIZE=2048k
command = sprintf('SET KMP_STACKSIZE=2048k & "%s" -p ansys -smp -np 2 -lch -dir "%s" -j "%s" -s read -l en-us -b -i "%s" -o "%s"',...
    ANSYS_dir, ANSYS_Mdir, ANSYS_JName, ANSYS_iFdir, ANSYS_oFdir);
% status = 0 表示成功运行
status = system(command);
end
