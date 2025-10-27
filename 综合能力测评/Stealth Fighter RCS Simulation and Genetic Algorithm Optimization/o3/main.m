%% stealth_RCS_GA.m
% *******************************************************
%  Stealth fighter modelling + PO RCS simulation + GA
%  Author :  ChatGPT demo
%  MATLAB  : R2021a or later (requires Global Opt Toolbox)
% *******************************************************

clear; clc; close all
rng(7)                                % 保证可重复

%% Radar / simulation parameters
lambda = 0.03;                        % 波长 0.03 m (≈10 GHz X‑band)
k      = 2*pi/lambda;                % 波数
az     = 0:5:355;                     % 方位角 φ
el     = -90:5:90;                    % 俯仰角 θ
[AZ,EL] = meshgrid(az,el);            % 网格

%% 基础尺寸(单位 m, 固定) —— 只优化各平面的倾斜角
sizePar.Len  = 15;    % 机身长
sizePar.Wing = 10;    % 翼展
sizePar.H    =  3;    % 厚度/高度
sizePar.Tail =  4;    % 尾翼展

%% 初始化角度（°）：[前机身, 上表面, 侧壁, 机翼, 垂尾, 进气道]
x0 = [60, 10, 75, 35, 35, 65];        % 初始“隐身”外形

%% ------ 1. 画出初始模型并算 RCS ----------------------
facet = buildFighter(x0, sizePar);    % 生成面元
figure; showFighter(facet); title('Initial fighter (x_0)');

[RCS0, RCSmap0] = calcRCS(facet, AZ, EL, lambda);
%% 绘制初始 RCS 球面图
figure;
surf(AZ,EL,RCSmap0,'edgecolor','none'); view(2); colormap jet; colorbar
title('Initial average RCS (dBsm)'); xlabel('\phi (deg)'); ylabel('\theta (deg)');

fprintf('Initial mean RCS  = %.2f dBsm\n', 10*log10(mean(RCS0)));

%% ------ 2. 用 GA 优化六个倾角 --------------------------
lb = [30  0 60 10 10 30];            % 下界
ub = [80 45 90 60 60 80];            % 上界

gaOpts = optimoptions('ga', ...
    'PopulationSize',50,...
    'MaxGenerations',40,...
    'PlotFcn',{@gaplotbestf},...
    'UseParallel',false,...
    'Display','iter');

costFun = @(x) fitnessRCS(x, sizePar, AZ, EL, lambda);  % 适应度

[xOpt, fval] = ga(costFun, numel(x0), [],[],[],[], lb, ub, [], gaOpts);

fprintf('\nOptimised angles  : %s (deg)\n', mat2str(xOpt,3));
fprintf('Optimised mean RCS= %.2f dBsm\n', fval);

%% ------ 3. 结果可视化 ---------------------------------
facetOpt = buildFighter(xOpt, sizePar);

figure; showFighter(facetOpt); title('Optimised fighter');

[~, RCSmapOpt] = calcRCS(facetOpt, AZ, EL, lambda);

figure;
subplot(1,2,1)
surf(AZ,EL,RCSmap0,'edgecolor','none'); view(2); colormap jet; colorbar
title('Initial RCS (dBsm)'); xlabel('\phi'); ylabel('\theta');

subplot(1,2,2)
surf(AZ,EL,RCSmapOpt,'edgecolor','none'); view(2); colormap jet; colorbar
title('Optimised RCS (dBsm)'); xlabel('\phi'); ylabel('\theta');

% 也可以显示 RCS 减小量
figure;
surf(AZ,EL,RCSmap0-RCSmapOpt,'edgecolor','none'); view(2); colormap parula; colorbar
title('RCS reduction (dB)'); xlabel('\phi'); ylabel('\theta');

disp('Done!');

%% ================== 局部函数 ===========================
function facet = buildFighter(ang, S)
% 根据六个倾斜角(°)返回面元信息：facet(i).normal, area, centre
% 简单几何：每一大面看成矩形，单位向量按欧拉旋转得到
deg = @(x) x*pi/180;

len = S.Len; BW=S.Wing; H=S.H; tail=S.Tail;

% 前机身(菱角)简化为一个大斜面
facet(1).area   = 0.5*H*len*0.6;
facet(1).norm   = rotateVec([1 0 0], [0 ang(1) 0]);

% 上表面
facet(2).area   = len*BW*0.5;
facet(2).norm   = rotateVec([0 0 1], [ang(2) 0 0]);

% 侧壁(左+右合并视为一面)
facet(3).area   = len*H;
facet(3).norm   = rotateVec([0 1 0], [0 ang(3) 0]);

% 机翼(两侧合并)
facet(4).area   = BW*len*0.25;
facet(4).norm   = rotateVec([0 -1 1], [0 ang(4) 0]);

% 垂尾
facet(5).area   = tail*H;
facet(5).norm   = rotateVec([0 1 0], [0 ang(5) 90]);

% 进气道(腹板)
facet(6).area   = 0.5*len*H;
facet(6).norm   = rotateVec([0 0 -1], [ang(6) 0 0]);
end

% -------------------------------------------------------
function vRot = rotateVec(v, angXYZ)
% 依次绕 X,Y,Z 旋转 angXYZ(°)
R = angle2dcm(angXYZ(3)*pi/180, angXYZ(2)*pi/180, angXYZ(1)*pi/180,'ZYX');
vRot = (R*v.').';
vRot = vRot / norm(vRot);
end

% -------------------------------------------------------
function [rcsVec, rcsMap] = calcRCS(facet, AZ, EL, lambda)
% 基于简化 PO： σ_i = 4π A_i^2 / λ^2 · cos^4(ψ_i) ，ψ_i 为入射与法向夹角
% 总 RCS = Σ σ_i
k = 2*pi/lambda;
[rows,cols]=size(AZ);
rcsMap = zeros(rows,cols);
dirVec = [cosd(EL(:)).*cosd(AZ(:)), cosd(EL(:)).*sind(AZ(:)), sind(EL(:))]; % 入射单位向量

for m = 1:numel(AZ)
    sig = 0;
    for i = 1:numel(facet)
        cospsi = max(0, dot(-dirVec(m,:), facet(i).norm)); % 入射对法线的余弦
        sig = sig + 4*pi*(facet(i).area.^2)/(lambda^2) * (cospsi).^4;
    end
    rcsMap(m) = 10*log10(sig+eps);     % dBsm
end

rcsMap = reshape(rcsMap, rows, cols);
rcsVec = rcsMap(:);
end

% -------------------------------------------------------
function f = fitnessRCS(x, S, AZ, EL, lambda)
% GA 适应度：平均 RCS（dBsm） —— 越小越好
facet = buildFighter(x, S);
[rcsVec, ~] = calcRCS(facet, AZ, EL, lambda);
f = mean(rcsVec);
end

% -------------------------------------------------------
function showFighter(facet)
% 仅用法向长度表示面；只做示意
hold on; axis equal; grid on
colors = lines(numel(facet));
for i=1:numel(facet)
    n  = facet(i).norm;
    quiver3(0,0,0, n(1),n(2),n(3), facet(i).area^0.5/5,'LineWidth',2,'Color',colors(i,:));
end
xlabel('x'); ylabel('y'); zlabel('z');
title('Facet normals (vectors length ∝ √area)');
view(35,20)
end
