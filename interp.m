%% function
% interpolation
%
% Xu Yi, 2022.5.12

%%
function [x,y,z] = interp(x1, x2, Num, n)
x = (x2(1) - x1(1)) / (Num + 1) * n + x1(1);
y = (x2(2) - x1(2)) / (Num + 1) * n + x1(2);
z = (x2(3) - x1(3)) / (Num + 1) * n + x1(3);
end