%% function
% calculate the distance of 2 point in 3D
%
% Xu Yi, 2022.5.18

%%
function dist = dist_2p3D(p1, p2)
dist = sqrt( (p1(1) - p2(1))^2 + ...
    (p1(2) - p2(2))^2 + ...
    (p1(3) - p2(3))^2 ...
    );
end