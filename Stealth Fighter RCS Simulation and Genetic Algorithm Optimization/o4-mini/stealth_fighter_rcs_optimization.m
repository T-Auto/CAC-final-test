% stealth_fighter_rcs_optimization.m
% 隐身战斗机 RCS 建模与遗传算法优化
% 2025-04-17 风雪

clear; clc; close all;

%% 全局参数
c = 3e8;                   % 光速 (m/s)
f = 10e9;                  % 雷达频率 10 GHz
lambda = c / f;            % 波长
incident_dirs = generate_dirs(0:10:360, 0:10:180); % 入射方向 [azimuth, elevation] grid

%% 遗传算法设置
nVar = 4;                  % 设计变量个数 [翼展, 翼弦比, 机身长度, 后掠角]
lb = [10, 4, 20, 0 ];      % 下界：翼展10m，翼弦比4，机长20m，后掠0°
ub = [20, 12, 30, 45];     % 上界：翼展20m，翼弦比12，机长30m，后掠45°

opts = optimoptions('ga',...
    'PopulationSize', 50,...
    'MaxGenerations', 40,...
    'Display', 'iter',...
    'PlotFcn', @gaplotbestf);

%% 运行遗传算法
[x_opt, fval, exitflag, output] = ga(@fitness_rcs, nVar, [], [], [], [], lb, ub, [], opts);

fprintf('最优设计：翼展=%.2fm，翼弦比=%.2f，机身长=%.2fm，后掠角=%.2f°\n', ...
    x_opt(1), x_opt(2), x_opt(3), x_opt(4));
fprintf('最优平均 RCS = %.2f dBsm\n', 10*log10(-fval));

%% 可视化：最优几何与 RCS 分布
figure('Name','最优隐身战斗机模型');
[faces, verts] = build_model(x_opt);
patch('Faces',faces,'Vertices',verts,'FaceColor',[0.7 0.7 0.8],'EdgeColor','none');
camlight; lighting gouraud; axis equal; grid on;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title('最优隐身战斗机三维模型');

% 计算并绘制极坐标 RCS
sigma_opt = compute_rcs(x_opt, incident_dirs, lambda);
az = incident_dirs(:,1);
figure('Name','RCS 极坐标分布');
polarplot(deg2rad(az), 10*log10(sigma_opt),'LineWidth',2);
title('最优设计下各方位平均 RCS 分布');

%% 局部函数：生成入射方向列表
function dirs = generate_dirs(azi_vec, ele_vec)
    [A,E] = meshgrid(azi_vec, ele_vec);
    dirs = [A(:), E(:)];
end

%% 局部函数：构建几何模型（平板网格）
function [F, V] = build_model(x)
    b = x(1);    % 翼展
    AR = x(2);  % 翼弦比
    L = x(3);    % 机身长度
    sweep = x(4);% 后掠角 (deg)

    % 机身：长方体近似
    fuselage = make_box([0,0,0], L, 1, 1);

    % 机翼：矩形平板，后掠
    c = b/AR;
    wing = make_plate([L*0.3,0,0.5], b, c, sweep);

    % 垂尾与水平尾同理
    htail = make_plate([L*0.9,0,0.5], b*0.3, c*0.4, 0);
    vtail = make_plate([L*0.9,0,0.5], b*0.1, 1, 90);

    % 合并所有面片
    V = [fuselage.V; wing.V; htail.V; vtail.V];
    F = fuselage.F;
    offset = size(fuselage.V,1);
    F = [F; wing.F + offset];
    offset = offset + size(wing.V,1);
    F = [F; htail.F + offset];
    offset = offset + size(htail.V,1);
    F = [F; vtail.F + offset];
end

%% 生成长方体函数
function box = make_box(center, L, W, H)
    x0 = center(1); y0=center(2); z0=center(3);
    V = [0  W/2  H/2; 0 -W/2  H/2; L  -W/2  H/2; L  W/2 H/2;
         0  W/2 -H/2; 0 -W/2 -H/2; L  -W/2 -H/2; L  W/2 -H/2];
    V = V + repmat([x0,y0,z0],8,1);
    F = [1 2 3 4; 5 8 7 6; 1 5 6 2; 2 6 7 3; 3 7 8 4; 4 8 5 1];
    box.F = F; box.V = V;
end

%% 生成平板函数（中心点、长度、宽度、旋转角）
function plate = make_plate(center, L, W, theta)
    % 在 XY 平面，以 center 为中心，绕 Z 轴旋转 theta
    V = [-L/2 -W/2 0;  L/2 -W/2 0;  L/2 W/2 0; -L/2 W/2 0];
    Rz = [cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1];
    V = (Rz * V')' + repmat([center(1), center(2), center(3)],4,1);
    F = [1 2 3 4];
    plate.F = F; plate.V = V;
end

%% 局部函数：计算 RCS 目标函数（求平均负 RCS dBsm）
function J = fitness_rcs(x)
    % 负平均 dBsm，用于最小化
    global incident_dirs lambda
    sigma = compute_rcs(x, incident_dirs, lambda);
    J = -mean(10*log10(sigma)); 
end

%% 计算 RCS 的函数
function sigma = compute_rcs(x, dirs, lambda)
    [F,V] = build_model(x);
    % 计算每个面片中心和法向
    nF = size(F,1);
    centers = zeros(nF,3);
    normals = zeros(nF,3);
    areas = zeros(nF,1);
    for i=1:nF
        pts = V(F(i,:),:);
        centers(i,:) = mean(pts,1);
        N = cross(pts(2,:)-pts(1,:), pts(3,:)-pts(1,:));
        normals(i,:) = N / norm(N);
        areas(i) = norm(N)/2;
    end

    nDirs = size(dirs,1);
    sigma = zeros(nDirs,1);
    for k=1:nDirs
        az = dirs(k,1); el = dirs(k,2);
        % 入射方向单位矢量
        dirV = [cosd(el)*cosd(az), cosd(el)*sind(az), sind(el)];
        % 单一极化下单面片 RCS 近似
        incos = max(0, dot(normals, repmat(dirV,nF,1),2));
        sigma_k = sum((4*pi*(areas.^2)/lambda^2) .* (incos.^2));
        sigma(k) = sigma_k;
    end
end
