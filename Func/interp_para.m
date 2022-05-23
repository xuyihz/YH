%% function
% parabola interpolation
% x1: 起点坐标(x,y,z); x2: 终点坐标;
% Num: 间隔点数量; n: 间隔点序号(自x1至x2增大)
% f: 抛物线跨中垂度(向下为正)
% Xu Yi, 2022.5.22

%%
function z3 = interp_para(x1, x2, Num, n, f)
% z = -4fx(l-x)/l^2 + c/l*x % z1=0的情况,c=z2-z1
z1 = x1(3); z2 = x2(3);
% x/l = n/(Num + 1)
z3 = -4*f*n*((Num + 1)-n)/(Num + 1)^2 +...   % 垂度
    (z2 - z1) / (Num + 1) * n + z1;         % 两端点
end