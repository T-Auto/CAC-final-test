%% stealth_RCS_GA.m
% *******************************************************
%  隐身飞机建模 + PO RCS 仿真 + GA 优化
%  作者 :  ChatGPT 演示
%  MATLAB : R2021a 或更高版本 (需要 Global Optimization Toolbox)
% *******************************************************

clear; clc; close all
rng(7)                                % 保证可重复性

%% 雷达 / 仿真参数
lambda = 0.03;                        % 波长 0.03 m (≈10 GHz X‑band)
k      = 2*pi/lambda;                 % 波数
az     = 0:5:355;                     % 方位角 φ (phi)
el     = -90:5:90;                    % 俯仰角 θ (theta)
[AZ,EL] = meshgrid(az,el);            % 生成角度网格

%% 基础尺寸参数 (单位 m, 固定) —— 只优化各主要平面的倾斜角
sizePar.Len  = 15;    % 机身长度
sizePar.Wing = 10;    % 翼展 (全翼展)
sizePar.H    =  3;    % 机身最大厚度/高度
sizePar.Tail =  4;    % 垂尾高度 (单个)
sizePar.Sweep = 30;   % 机翼后掠角 (度) - 添加一个用于绘图的参数
sizePar.TailSweep = 40; % 垂尾后掠角 (度) - 添加

%% 初始化角度（°）：[前机身倾角, 上表面倾角, 侧壁倾角, 机翼上反角, 垂尾外倾角, 进气道(底部)倾角]
% 注意：这些角度用于RCS计算中的法向量定义，并在showFighter3D中用于可视化调整
x0 = [60, 10, 75, 5, 20, 65];        % 初始“隐身”外形角度

%% ------ 1. 生成初始模型, 计算 RCS 并显示 ----------------------
facet = buildFighter(x0, sizePar);    % 生成面元信息 (用于RCS计算)

% --- 显示初始三维模型 ---
figure;
showFighter3D(x0, sizePar);
title('初始飞机三维模型 (x_0)');
% --- 原来的法向量显示 (可选) ---
% figure; showFighter(facet); title('初始模型法向量');

[RCS0, RCSmap0] = calcRCS(facet, AZ, EL, lambda); % 计算RCS

% --- 绘制初始 RCS 球面图 ---
figure;
surf(AZ,EL,RCSmap0,'edgecolor','none'); view(2); colormap jet; colorbar
axis tight;
title('初始模型平均 RCS (dBsm)'); xlabel('方位角 \phi (度)'); ylabel('俯仰角 \theta (度)');

fprintf('初始模型 平均 RCS  = %.2f dBsm\n', mean(RCSmap0(:))); % 使用 mean(RCSmap0(:)) 更准确

%% ------ 2. 使用 GA 优化六个倾角 --------------------------
% 定义角度的下界和上界
lb = [30  0 60  0 10 30];            % 下界 (度)
ub = [80 45 90 45 45 80];            % 上界 (度)

% GA 优化选项
gaOpts = optimoptions('ga', ...
    'PopulationSize',50,...          % 种群大小
    'MaxGenerations',40,...          % 最大迭代次数
    'PlotFcn',{@gaplotbestf},...     % 绘制最优适应度函数值的变化
    'UseParallel',false,...          % 是否使用并行计算 (需要 Parallel Computing Toolbox)
    'Display','iter');               % 显示迭代信息

% 定义适应度函数 (目标是最小化平均 RCS)
costFun = @(x) fitnessRCS(x, sizePar, AZ, EL, lambda);

% --- 运行遗传算法 ---
[xOpt, fval] = ga(costFun, numel(x0), [],[],[],[], lb, ub, [], gaOpts);

fprintf('\n优化后的角度      : %s (度)\n', mat2str(round(xOpt,2)));
fprintf('优化后的平均 RCS = %.2f dBsm\n', fval);

%% ------ 3. 优化结果可视化 ---------------------------------
facetOpt = buildFighter(xOpt, sizePar); % 生成优化后的面元信息

% --- 显示优化后的三维模型 ---
figure;
showFighter3D(xOpt, sizePar);
title('优化后的飞机三维模型');

% --- 计算优化后的 RCS ---
[~, RCSmapOpt] = calcRCS(facetOpt, AZ, EL, lambda);

% --- 对比显示初始和优化后的 RCS 图 ---
figure;
subplot(1,2,1)
surf(AZ,EL,RCSmap0,'edgecolor','none'); view(2); colormap jet; colorbar
axis tight;
title('初始 RCS (dBsm)'); xlabel('\phi'); ylabel('\theta');

subplot(1,2,2)
surf(AZ,EL,RCSmapOpt,'edgecolor','none'); view(2); colormap jet; colorbar
axis tight;
title('优化后 RCS (dBsm)'); xlabel('\phi'); ylabel('\theta');

% --- 显示 RCS 减小量 ---
figure;
surf(AZ,EL,RCSmap0-RCSmapOpt,'edgecolor','none'); view(2); colormap parula; colorbar
axis tight;
title('RCS 减小量 (dB)'); xlabel('方位角 \phi (度)'); ylabel('俯仰角 \theta (度)');

disp('计算完成!');

%% ================== 局部函数 ===========================

function facet = buildFighter(ang, S)
% 根据六个倾斜角(°)和尺寸参数(S)返回面元信息：facet(i).normal, area
% 这个函数主要用于RCS计算，定义了几个关键表面的法向量和估算面积
% ang: [前机身, 上表面, 侧壁, 机翼, 垂尾, 进气道] 倾角 (度)
% S: 尺寸结构体 (Len, Wing, H, Tail)

deg = @(x) x*pi/180; % 角度转弧度

len = S.Len; BW = S.Wing; H = S.H; tailH = S.Tail; % 使用 S 结构体中的字段名

% --- 定义各部分的法向量和估算面积 ---
% 注意：这里的面积是简化的估算值，法向量由角度确定

% 1. 前机身 (简化为一个大斜面)
% 法向量: 初始指向+x，绕y轴旋转 ang(1) 度
facet(1).norm   = rotateVec([1 0 0], [0, ang(1), 0]);
facet(1).area   = 0.5 * H * len * 0.4; % 估算面积

% 2. 上表面
% 法向量: 初始指向+z，绕x轴旋转 ang(2) 度 (机头方向为+x)
facet(2).norm   = rotateVec([0 0 1], [ang(2), 0, 0]);
facet(2).area   = len * BW * 0.3; % 估算面积

% 3. 侧壁 (左右合并视为一个等效面，法向量向外倾斜)
% 法向量: 初始指向+y，绕x轴旋转 ang(3) 度 (使其向外倾斜)
% 修改：原代码绕Y轴转，更像是改变侧面轮廓线，改为绕X轴转以实现外倾
facet(3).norm   = rotateVec([0 1 0], [ang(3), 0, 0]); % 绕 X 轴旋转实现外倾
facet(3).area   = len * H * 0.6; % 估算两侧总面积

% 4. 机翼 (两侧合并，考虑上反/下反角)
% 法向量: 初始指向+z (代表翼面法向)，绕x轴旋转 ang(4) 度 (上反为正)
facet(4).norm   = rotateVec([0 0 1], [ang(4), 0, 0]); % 简化：用法向上倾代表上反角影响
facet(4).area   = BW * len * 0.35; % 估算机翼总面积

% 5. 垂尾 (两侧合并，考虑外倾角)
% 法向量: 初始指向+y (代表侧向)，绕x轴旋转 ang(5) 度 (外倾为正)
facet(5).norm   = rotateVec([0 1 0], [ang(5), 0, 0]); % 绕 X 轴旋转实现外倾
facet(5).area   = tailH * len * 0.15 * 2; % 估算双垂尾总面积

% 6. 进气道/底部
% 法向量: 初始指向-z，绕x轴旋转 ang(6) 度
facet(6).norm   = rotateVec([0 0 -1], [ang(6), 0, 0]);
facet(6).area   = len * BW * 0.2; % 估算面积

% --- 归一化法向量 ---
for i = 1:numel(facet)
    facet(i).norm = facet(i).norm / norm(facet(i).norm);
end

end

% -------------------------------------------------------
function vRot = rotateVec(v, angXYZ_deg)
% 使用ZYX欧拉角顺序，将向量v按 angXYZ_deg(°) 旋转
% angXYZ_deg = [angX, angY, angZ] (度)
angX_rad = angXYZ_deg(1) * pi / 180;
angY_rad = angXYZ_deg(2) * pi / 180;
angZ_rad = angXYZ_deg(3) * pi / 180;

% 构建旋转矩阵 (ZYX顺序)
% R = rotz(angZ_deg) * roty(angY_deg) * rotx(angX_deg); % MATLAB R2016b+
% 手动构建或使用 angle2dcm
R = angle2dcm(angZ_rad, angY_rad, angX_rad, 'ZYX'); % ZYX顺序

vRot = (R * v(:)).'; % 应用旋转，确保v是列向量，结果转回行向量
vRot = vRot / norm(vRot); % 保持单位向量 (如果输入是单位向量)
end

% -------------------------------------------------------
function [rcsVec, rcsMap] = calcRCS(facet, AZ, EL, lambda)
% 基于简化物理光学法 (PO) 计算 RCS
% 公式简化为：σ_total = Σ |sqrt(σ_i)|^2 ≈ Σ (2*pi*A_i/lambda * cos(ψ_i))^2
% 或者更简化的 σ_i = (4*pi*A_i^2 / lambda^2) * cos^4(ψ_i)
% 这里使用后者：σ_total = Σ σ_i
% ψ_i 是入射方向向量与面元 i 法向量的夹角
% 注意：这个PO模型非常简化，忽略了边缘衍射等效应

k = 2*pi/lambda;
[rows,cols]=size(AZ);
rcsMap = zeros(rows,cols);

% 将球面网格角度转换为笛卡尔坐标方向向量 (单位向量)
% MATLAB 的 sind/cosd 使用度作为输入
az_rad = AZ * pi/180;
el_rad = EL * pi/180;
sx = cos(el_rad) .* cos(az_rad); % x分量
sy = cos(el_rad) .* sind(az_rad); % y分量
sz = sin(el_rad);                 % z分量
dirVec = [sx(:), sy(:), sz(:)];   % N x 3 矩阵，N = rows*cols

num_angles = size(dirVec, 1);
num_facets = numel(facet);
sigma_total = zeros(num_angles, 1);

% 对每个面元计算其贡献
for i = 1:num_facets
    normal_i = facet(i).norm;
    area_i = facet(i).area;

    % 计算入射方向与法向量的点积 (cos(π - ψ_i) = -cos(ψ_i))
    % 我们需要 cos(ψ_i)，所以是 -dot(dirVec, normal_i)
    % dirVec 是 (N x 3), normal_i 是 (1 x 3)
    % 使用 bsxfun 或直接矩阵乘法
    cos_psi_i = - dirVec * normal_i'; % 结果是 N x 1 向量

    % 确保 cos_psi_i >= 0 (只考虑正面照射)
    cos_psi_i = max(0, cos_psi_i);

    % 计算该面元的 RCS 贡献 (线性值)
    % sigma_i = (k^2 / pi) * (area_i * cos_psi_i)^2; % 另一种 PO 近似
    sigma_i = 4*pi*(area_i^2)/(lambda^2) * (cos_psi_i).^4; % 使用代码中的公式

    % 累加总 RCS (线性值)
    sigma_total = sigma_total + sigma_i;
end

% 转换为 dBsm
rcsMap = 10*log10(sigma_total + eps); % 加 eps 防止 log10(0)

rcsMap = reshape(rcsMap, rows, cols); % 恢复为网格形状
rcsVec = rcsMap(:);                   % 返回向量形式 (用于适应度函数)
end

% -------------------------------------------------------
function f = fitnessRCS(x, S, AZ, EL, lambda)
% GA 适应度函数：计算给定角度 x 下的平均 RCS（dBsm）
% 目标是最小化这个值
facet = buildFighter(x, S);           % 根据当前角度 x 生成面元
[~, rcsMap] = calcRCS(facet, AZ, EL, lambda); % 计算 RCS 图
f = mean(rcsMap(:));                  % 计算所有角度下的平均 RCS (dBsm)
% 可以考虑加权平均，例如更关注前方 RCS
% f = mean(rcsMap(abs(AZ)<90 & abs(EL)<30)); % 仅前向平均示例
end

% -------------------------------------------------------
function showFighter(facet)
% (原函数) 仅用法向向量显示面元信息；只做示意
% 向量长度与面积的平方根成正比
hold on; axis equal; grid on;
colors = lines(numel(facet)); % 为不同面元使用不同颜色
origin = [0,0,0];
scale_factor = 0.1; % 调整比例因子以控制向量显示长度

for i=1:numel(facet)
    n  = facet(i).norm;
    len = sqrt(facet(i).area) * scale_factor; % 长度与面积平方根成正比
    quiver3(origin(1), origin(2), origin(3), ...
            n(1), n(2), n(3), len, ...
            'LineWidth', 2, 'Color', colors(i,:), 'AutoScale', 'off');
end
xlabel('X轴 (机头方向)'); ylabel('Y轴 (右翼方向)'); zlabel('Z轴 (向上)');
title('模型各面元法向量 (长度 \propto \surd{面积})');
view(35,20); % 设置视角
axis tight;
legend('前体','上表面','侧壁','机翼','垂尾','进气道/底部'); % 添加图例
hold off;
end

% -------------------------------------------------------
function showFighter3D(ang, S)
% 新函数：绘制简化的飞机三维几何模型
% ang: [前机身, 上表面, 侧壁, 机翼, 垂尾, 进气道] 倾角 (度)
% S: 尺寸结构体 (Len, Wing, H, Tail, Sweep, TailSweep)

L = S.Len;      % 总长
W = S.Wing;     % 翼展
H = S.H;        % 高度
T = S.Tail;     % 垂尾高
sweep_deg = S.Sweep; % 机翼后掠角
tail_sweep_deg = S.TailSweep; % 垂尾后掠角

% --- 定义关键点坐标 (基于原点在机身中心附近) ---
nose_tip = [L/2, 0, 0];
fuselage_front_top = [L/2*0.8, 0, H/2];
fuselage_front_bot = [L/2*0.8, 0, -H/2];
fuselage_rear_top = [-L/2, 0, H/2*0.8];
fuselage_rear_bot = [-L/2, 0, -H/2*0.8];
wing_root_le = [L/2*0.2, 0, 0]; % 机翼根部前缘
wing_root_te = [-L/2*0.6, 0, 0]; % 机翼根部后缘
tail_root_le = [-L/2*0.7, 0, H/2*0.8]; % 垂尾根部前缘
tail_root_te = [-L/2, 0, H/2*0.8]; % 垂尾根部后缘

% --- 计算翼尖和尾尖坐标 (考虑后掠) ---
wing_tip_y = W/2;
wing_tip_le_x = wing_root_le(1) - wing_tip_y * tan(sweep_deg * pi/180);
wing_tip_te_x = wing_root_te(1) - wing_tip_y * tan(sweep_deg * pi/180);
wing_tip_le = [wing_tip_le_x, wing_tip_y, 0];
wing_tip_te = [wing_tip_te_x, wing_tip_y, 0];

tail_tip_z = tail_root_le(3) + T;
tail_tip_le_x = tail_root_le(1) - T * tan(tail_sweep_deg * pi/180);
tail_tip_te_x = tail_root_te(1) - T * tan(tail_sweep_deg * pi/180);
tail_tip_le = [tail_tip_le_x, 0, tail_tip_z]; % 假设根部在中心线
tail_tip_te = [tail_tip_te_x, 0, tail_tip_z];

% --- 定义旋转矩阵 (用于应用倾角) ---
rotX = @(a) [1 0 0; 0 cosd(a) -sind(a); 0 sind(a) cosd(a)];
rotY = @(a) [cosd(a) 0 sind(a); 0 1 0; -sind(a) 0 cosd(a)];
rotZ = @(a) [cosd(a) -sind(a) 0; sind(a) cosd(a) 0; 0 0 1];

% --- 获取角度 ---
nose_angle = ang(1); % 前体倾角 (影响前锥形状) - 简化处理
top_angle = ang(2);  % 上表面倾角 (绕X轴)
side_angle = ang(3); % 侧壁倾角 (绕X轴) - 外倾
wing_dihedral = ang(4); % 机翼上反角 (绕X轴)
tail_cant = ang(5);   % 垂尾外倾角 (绕X轴)
bottom_angle = ang(6);% 底部/进气道倾角 (绕X轴)

% --- 绘制各部分 ---
hold on; grid on; axis equal;
view(30, 20); % 设置初始观察角度
xlabel('X轴 (机头)'); ylabel('Y轴 (右翼)'); zlabel('Z轴 (向上)');
light; lighting gouraud; % 添加光源
material dull; % 设置材质

% --- 1. 机身 (简化为多边形棱柱) ---
% 定义机身截面 (简化为菱形或六边形)
fuselage_width_ratio = 0.15; % 机身宽度相对于翼展的比例
fw = W * fuselage_width_ratio / 2; % 半宽
fh_top = H/2;
fh_bot = -H/2;
% 前截面顶点 (考虑侧壁倾角 side_angle)
p_f_top = fuselage_front_top;
p_f_bot = fuselage_front_bot;
p_f_r = (rotX(side_angle) * [fuselage_front_top(1); fw; 0])'; % 右侧点
p_f_l = (rotX(side_angle) * [fuselage_front_top(1); -fw; 0])';% 左侧点
% 后截面顶点
p_r_top = fuselage_rear_top;
p_r_bot = fuselage_rear_bot;
p_r_r = (rotX(side_angle) * [fuselage_rear_top(1); fw*0.8; 0])'; % 后部稍窄
p_r_l = (rotX(side_angle) * [fuselage_rear_top(1); -fw*0.8; 0])';

% 绘制机身侧面、顶面、底面 (使用 patch)
% 顶面 (前点->后点) - 考虑上表面倾角 top_angle
top_verts_initial = [p_f_top; p_r_top; p_r_l; p_f_l];
top_center = mean(top_verts_initial);
top_verts_rotated = (rotX(top_angle) * (top_verts_initial - top_center)')' + top_center;
patch('Vertices', top_verts_rotated, 'Faces', [1 2 3 4], 'FaceColor', [0.5 0.5 0.6]);

% 底面 (前点->后点) - 考虑底部倾角 bottom_angle
bot_verts_initial = [p_f_bot; p_r_bot; p_r_l; p_f_l]; % 使用侧面点定义宽度
bot_center = mean(bot_verts_initial);
bot_verts_rotated = (rotX(bottom_angle) * (bot_verts_initial - bot_center)')' + bot_center;
patch('Vertices', bot_verts_rotated, 'Faces', [1 2 3 4], 'FaceColor', [0.6 0.6 0.7]);

% 右侧面
patch('Vertices', [p_f_top; p_r_top; p_r_r; p_f_r], 'Faces', [1 2 3 4], 'FaceColor', [0.7 0.7 0.8]);
patch('Vertices', [p_f_bot; p_r_bot; p_r_r; p_f_r], 'Faces', [1 2 3 4], 'FaceColor', [0.7 0.7 0.8]); % 下半侧面

% 左侧面
patch('Vertices', [p_f_top; p_r_top; p_r_l; p_f_l], 'Faces', [1 2 3 4], 'FaceColor', [0.7 0.7 0.8]);
patch('Vertices', [p_f_bot; p_r_bot; p_r_l; p_f_l], 'Faces', [1 2 3 4], 'FaceColor', [0.7 0.7 0.8]); % 下半侧面

% 前部封闭 (简化 - 连接前顶点) - 可视化效果可能不好，省略或简化
% patch('Vertices', [nose_tip; p_f_top; p_f_r], 'Faces', [1 2 3], 'FaceColor', [0.5 0.5 0.6]);
% patch('Vertices', [nose_tip; p_f_top; p_f_l], 'Faces', [1 2 3], 'FaceColor', [0.5 0.5 0.6]);
% patch('Vertices', [nose_tip; p_f_bot; p_f_r], 'Faces', [1 2 3], 'FaceColor', [0.6 0.6 0.7]);
% patch('Vertices', [nose_tip; p_f_bot; p_f_l], 'Faces', [1 2 3], 'FaceColor', [0.6 0.6 0.7]);

% 后部封闭 (简化)
patch('Vertices', [p_r_top; p_r_bot; p_r_r], 'Faces', [1 2 3], 'FaceColor', [0.6 0.6 0.6]);
patch('Vertices', [p_r_top; p_r_bot; p_r_l], 'Faces', [1 2 3], 'FaceColor', [0.6 0.6 0.6]);


% --- 2. 机翼 ---
% 定义右翼顶点 (梯形)
wing_r_verts_initial = [wing_root_le; wing_root_te; wing_tip_te; wing_tip_le];
% 计算旋转中心 (近似为根部中点)
wing_rot_center = (wing_root_le + wing_root_te) / 2;
% 应用上反角 (绕X轴旋转)
wing_r_verts_rotated = (rotX(wing_dihedral) * (wing_r_verts_initial - wing_rot_center)')' + wing_rot_center;
% 绘制右翼
patch('Vertices', wing_r_verts_rotated, 'Faces', [1 2 3 4], 'FaceColor', [0.8 0.8 0.8]);

% 定义左翼顶点 (Y坐标反向)
wing_l_verts_initial = wing_r_verts_initial;
wing_l_verts_initial(:,2) = -wing_l_verts_initial(:,2); % Y坐标取反
% 应用上反角 (同样绕X轴旋转)
wing_l_verts_rotated = (rotX(wing_dihedral) * (wing_l_verts_initial - wing_rot_center)')' + wing_rot_center;
% 绘制左翼
patch('Vertices', wing_l_verts_rotated, 'Faces', [1 2 3 4], 'FaceColor', [0.8 0.8 0.8]);


% --- 3. 垂尾 (假设双垂尾，对称放置在机身后部两侧) ---
tail_base_y = fw * 0.8; % 垂尾根部放置在机身宽度稍内侧

% 定义右垂尾顶点 (根部在右侧)
tail_r_root_le = [-L/2*0.7, tail_base_y, H/2*0.8];
tail_r_root_te = [-L/2, tail_base_y, H/2*0.8];
tail_r_tip_le = [tail_r_root_le(1) - T * tan(tail_sweep_deg*pi/180), tail_base_y, tail_r_root_le(3) + T];
tail_r_tip_te = [tail_r_root_te(1) - T * tan(tail_sweep_deg*pi/180), tail_base_y, tail_r_root_te(3) + T];
tail_r_verts_initial = [tail_r_root_le; tail_r_root_te; tail_r_tip_te; tail_r_tip_le];
% 计算旋转中心 (近似为根部中点)
tail_r_rot_center = (tail_r_root_le + tail_r_root_te) / 2;
% 应用外倾角 (绕X轴旋转, 正角度向外倾)
tail_r_verts_rotated = (rotX(tail_cant) * (tail_r_verts_initial - tail_r_rot_center)')' + tail_r_rot_center;
% 绘制右垂尾
patch('Vertices', tail_r_verts_rotated, 'Faces', [1 2 3 4], 'FaceColor', [0.7 0.7 0.7]);

% 定义左垂尾顶点 (根部在左侧, Y坐标反向)
tail_l_verts_initial = tail_r_verts_initial;
tail_l_verts_initial(:,2) = -tail_l_verts_initial(:,2); % Y坐标取反
% 计算旋转中心
tail_l_rot_center = tail_r_rot_center;
tail_l_rot_center(2) = -tail_l_rot_center(2);
% 应用外倾角 (绕X轴旋转, 负角度向外倾)
tail_l_verts_rotated = (rotX(-tail_cant) * (tail_l_verts_initial - tail_l_rot_center)')' + tail_l_rot_center;
% 绘制左垂尾
patch('Vertices', tail_l_verts_rotated, 'Faces', [1 2 3 4], 'FaceColor', [0.7 0.7 0.7]);

hold off;
end