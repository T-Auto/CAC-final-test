% main_stealth_optimization.m
% 主程序：隐身战斗机建模、RCS计算与遗传算法优化

clc;
clear;
close all;

%% 1. 定义仿真参数和初始模型参数

% 雷达参数
frequency = 10e9; % 雷达频率 (Hz), X波段
c = 299792458; % 光速 (m/s)
lambda = c / frequency; % 波长 (m)
k = 2 * pi / lambda; % 波数 (rad/m)

% 初始模型参数 [L, W_tail, H_tail, x_mid_frac, W_mid, H_mid_top]
% L: 长度
% W_tail: 尾部宽度
% H_tail: 尾部高度 (顶部)
% x_mid_frac: 最大宽度/高度位置占总长的比例 (0到1之间)
% W_mid: 最大宽度
% H_mid_top: 最大高度 (顶部)
% H_bottom 固定为 0 (平坦底部)
initial_params = [15, 3, 2, 0.5, 10, 4]; % 示例初始参数

% 遗传算法参数
nvars = length(initial_params); % 变量数量
% 变量的下界和上界 [10, 1, 1, 0.3, 5, 2] 到 [20, 5, 3, 0.7, 15, 6]
lb = [10, 1, 1, 0.3, 5, 2];
ub = [20, 5, 3, 0.7, 15, 6];

% 遗传算法选项
options = optimoptions('ga', ...
    'PopulationSize', 50, ... % 种群大小
    'MaxGenerations', 100, ... % 最大代数
    'EliteCount', 5, ... % 精英数量
    'CrossoverFraction', 0.8, ... % 交叉比例
    'MutationFcn', @mutationadaptfeasible, ... % 自适应可行变异函数
    ...'PlotFcn', @gaplotbestfcn, ... % 绘制最佳适应度函数 - 移除或注释掉此行
    'Display', 'iter'); % 显示迭代过程

% 定义用于计算适应度的关键RCS方向 (例如，水平面内的各个方向)
fitness_azimuths = 0:10:350; % 0到350度，每隔10度
fitness_elevation = 0; % 0度仰角 (水平面)
fitness_directions = [fitness_azimuths(:), repmat(fitness_elevation, length(fitness_azimuths), 1)];

%% 2. 运行遗传算法优化

fprintf('开始遗传算法优化...\n');
% 使用匿名函数将固定参数传递给适应度函数
% 注意：fitness_func 现在需要接收并传递 faces_cell 给 calculateRCS_PO
fitness_fcn_handle = @(params) fitness_func(params, frequency, fitness_directions);

% 调用遗传算法
[optimized_params, min_avg_rcs_linear] = ga(fitness_fcn_handle, nvars, [], [], [], [], lb, ub, [], options);

fprintf('\n优化完成。\n');
fprintf('初始参数: L=%.2f, W_tail=%.2f, H_tail=%.2f, x_mid_frac=%.2f, W_mid=%.2f, H_mid_top=%.2f\n', initial_params);
fprintf('优化参数: L=%.2f, W_tail=%.2f, H_tail=1.00, x_mid_frac=%.2f, W_mid=%.2f, H_mid_top=2.00\n', optimized_params); % 注意：这里打印优化参数时，H_tail和H_mid_top可能因为下界限制而固定在1.00和2.00附近，实际值以optimized_params为准
fprintf('优化后的平均线性RCS (用于适应度计算): %.4f\n', min_avg_rcs_linear);
fprintf('优化后的平均RCS (dBsm): %.2f dBsm\n', 10*log10(min_avg_rcs_linear));


%% 3. 可视化结果

% 3.1 绘制初始模型
figure('Name', '初始隐身战斗机模型');
% createStealthModel 现在返回 faces_patch_matrix (用于patch) 和 faces_cell (用于RCS)
[initial_vertices, initial_faces_patch, initial_normals, initial_areas, initial_centroids, initial_faces_cell] = createStealthModel(initial_params);
patch('Vertices', initial_vertices, 'Faces', initial_faces_patch, 'FaceColor', [0.5 0.7 0.9], 'EdgeColor', 'k');
axis equal;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('初始隐身战斗机模型');
view(3); % 3D视角
grid on;

% 3.2 绘制优化后的模型
figure('Name', '优化后的隐身战斗机模型');
[optimized_vertices, optimized_faces_patch, optimized_normals, optimized_areas, optimized_centroids, optimized_faces_cell] = createStealthModel(optimized_params);
patch('Vertices', optimized_vertices, 'Faces', optimized_faces_patch, 'FaceColor', [0.9 0.5 0.7], 'EdgeColor', 'k');
axis equal;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('优化后的隐身战斗机模型');
view(3); % 3D视角
grid on;

% 3.3 计算并绘制RCS方向图 (例如，水平面)
fprintf('\n计算初始和优化模型的RCS方向图 (水平面)...\n');
rcs_azimuths = 0:5:360; % 计算RCS的方位角范围
rcs_elevation = 0; % 计算RCS的仰角 (水平面)

% 计算初始模型的RCS
initial_rcs_dBsm = zeros(size(rcs_azimuths));
% 使用 initial_faces_cell 调用 calculateRCS_PO
for i = 1:length(rcs_azimuths)
    initial_rcs_dBsm(i) = calculateRCS_PO(initial_vertices, initial_faces_cell, initial_normals, initial_areas, initial_centroids, frequency, rcs_azimuths(i), rcs_elevation);
end

% 计算优化模型的RCS
optimized_rcs_dBsm = zeros(size(rcs_azimuths));
% 使用 optimized_faces_cell 调用 calculateRCS_PO
for i = 1:length(rcs_azimuths)
    optimized_rcs_dBsm(i) = calculateRCS_PO(optimized_vertices, optimized_faces_cell, optimized_normals, optimized_areas, optimized_centroids, frequency, rcs_azimuths(i), rcs_elevation);
end

% 绘制RCS方向图
figure('Name', 'RCS方向图 (水平面)');
polarplot(deg2rad(rcs_azimuths), initial_rcs_dBsm, 'b-', 'LineWidth', 1.5, 'DisplayName', '初始模型 RCS');
hold on;
polarplot(deg2rad(rcs_azimuths), optimized_rcs_dBsm, 'r-', 'LineWidth', 1.5, 'DisplayName', '优化模型 RCS');
title(sprintf('水平面RCS方向图 (%.1f GHz)', frequency/1e9));
legend('Location', 'best');
rlim([-40 20]); % 设置极坐标图的径向范围 (dBsm)
rticks(-40:10:20); % 设置径向刻度
grid on;
hold off;

% 3.4 绘制适应度历史 (如果需要，可以手动记录并在优化后绘制)
% 由于移除了 PlotFcn，GA不会自动绘制。如果需要，可以在 fitness_func 中记录每次调用的适应度，
% 并在优化完成后手动绘制。这里为了简化，跳过此步。

% 3.5 比较平均RCS (在用于适应度计算的关键方向上)
% fitness_func 内部会调用 createStealthModel 并使用 faces_cell 计算 RCS
initial_avg_rcs_linear = fitness_func(initial_params, frequency, fitness_directions);
optimized_avg_rcs_linear = fitness_func(optimized_params, frequency, fitness_directions);

fprintf('\n关键方向上的平均RCS比较:\n');
fprintf('初始模型平均RCS: %.2f dBsm\n', 10*log10(initial_avg_rcs_linear));
fprintf('优化模型平均RCS: %.2f dBsm\n', 10*log10(optimized_avg_rcs_linear));