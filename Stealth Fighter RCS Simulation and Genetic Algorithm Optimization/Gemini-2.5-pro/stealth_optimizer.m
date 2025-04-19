% MATLAB 程序：隐身战斗机建模、RCS仿真与遗传算法优化
%
% 功能：
% 1. 创建一个参数化的简化隐身战斗机模型 (菱形翼身融合)
% 2. 使用简化的面元法计算其在不同方向的 RCS
% 3. 可视化飞机模型和 RCS 方向图 (3D)
% 4. 使用遗传算法优化飞机设计参数以最小化平均 RCS
%
% 要求：MATLAB R2016b+, Global Optimization Toolbox
%--------------------------------------------------------------------------

clear; close all; clc;

% --- 全局参数设定 ---
freq = 10e9;             % 雷达频率 (Hz) - X波段
c = physconst('LightSpeed'); % 光速 (m/s)
lambda = c / freq;       % 波长 (m)

% --- 1. 简化隐身战斗机建模 ---
% 使用参数定义飞机外形 (示例：简化的菱形翼身融合体)
% 参数: [fuselageLength, maxFuselageWidth, wingSpan, wingSweepDeg, noseLengthRatio, tailHeight]
initial_params = [
    16,    % fuselageLength (m) - 机身（含翼区）总长
    3.5,   % maxFuselageWidth (m) - 机身最大宽度 (在中心)
    11,    % wingSpan (m) - 翼展
    55,    % wingSweepDeg (deg) - 机翼前缘后掠角
    0.35,  % noseLengthRatio (-) - 机头长度占总长比例
    1.8    % tailHeight (m) - 垂尾高度 (简化为两个倾斜面)
];

% 定义创建飞机几何形状的函数
[vertices_init, faces_init] = createStealthFighterGeometry(initial_params);

% --- 2. RCS 计算函数 (简化面元法) ---
% Function to calculate RCS for a given geometry, direction, and wavelength
% (将在 GA 目标函数和主脚本中使用)

% --- 3. RCS 全向仿真 ---
disp('正在计算初始设计的 RCS...');
% 定义仿真角度范围
azimuth = 0:10:360; % 方位角 (度) - 减少点数加速
elevation = -90:10:90; % 俯仰角 (度) - 减少点数加速
[PHI, THETA] = meshgrid(deg2rad(azimuth), deg2rad(elevation)); % 转换为弧度

% 初始化 RCS 结果矩阵 (线性单位 m^2)
rcs_pattern_init_m2 = zeros(size(PHI));

% 循环计算每个方向的 RCS
[rows, cols] = size(PHI);
h_wait = waitbar(0, '正在计算初始 RCS...');
total_calcs = numel(PHI);
count = 0;
for i = 1:rows
    for j = 1:cols
        phi = PHI(i,j);
        theta = THETA(i,j);
        % 雷达视线方向矢量 (从雷达指向目标)
        ux = cos(theta) * cos(phi);
        uy = cos(theta) * sin(phi);
        uz = sin(theta);
        radar_dir = [ux; uy; uz]; % 列向量

        % 计算该方向的 RCS (m^2)
        rcs_pattern_init_m2(i, j) = calculateFacetRCS(vertices_init, faces_init, radar_dir, lambda);

        count = count + 1;
        waitbar(count / total_calcs, h_wait);
    end
end
close(h_wait);

% 将 RCS 转换为 dBsm (分贝平方米)
rcs_pattern_init_dbsm = 10 * log10(rcs_pattern_init_m2 + eps); % 加 eps 防止 log10(0)

% 计算初始设计的平均 RCS (线性平均)
avg_rcs_init_m2 = mean(rcs_pattern_init_m2(:), 'omitnan');
avg_rcs_init_dbsm = 10*log10(avg_rcs_init_m2);
disp(['初始设计平均 RCS: ', num2str(avg_rcs_init_m2, '%.4f'), ' m^2 (', num2str(avg_rcs_init_dbsm, '%.2f'), ' dBsm)']);


% --- 4. 可视化 ---
% 4.1 可视化初始飞机模型
figure('Name', '初始隐身战斗机模型');
h_patch_init = patch('Vertices', vertices_init, 'Faces', faces_init, ...
      'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'k', 'FaceAlpha', 0.8);
axis equal; grid on; view(3);
xlabel('X (m) - 机头方向'); ylabel('Y (m)'); zlabel('Z (m)');
title('初始简化隐身战斗机模型');
rotate3d on;

% 4.2 可视化初始 RCS 方向图 (3D 球坐标)
figure('Name', '初始设计 RCS 方向图 (3D)');
% 将球坐标角度和RCS值转换为笛卡尔坐标用于绘图
max_r = max(rcs_pattern_init_dbsm(:), [], 'omitnan');
min_r = min(rcs_pattern_init_dbsm(:), [], 'omitnan');
if isinf(max_r) || isnan(max_r); max_r = 10; end % Handle potential Inf/NaN
if isinf(min_r) || isnan(min_r); min_r = -40; end

% 将dBsm值映射到一个半径上，进行偏移和缩放以优化可视化
vis_radius_offset = 30; % 将负dBsm值移到正数域的偏移量
vis_radius_scale = 1;   % 半径的缩放因子
rcs_radius = max(0, rcs_pattern_init_dbsm + vis_radius_offset) * vis_radius_scale;
rcs_radius(rcs_pattern_init_dbsm < -20) = 1; % 对非常低的RCS设置一个最小半径

% 转换到笛卡尔坐标
X_rcs = rcs_radius .* cos(THETA) .* cos(PHI);
Y_rcs = rcs_radius .* cos(THETA) .* sin(PHI);
Z_rcs = rcs_radius .* sin(THETA);

surf(X_rcs, Y_rcs, Z_rcs, rcs_pattern_init_dbsm, 'EdgeColor', 'none', 'FaceAlpha', 0.7);
hold on;
% 画一个参考球体
max_vis_radius = max(rcs_radius(:),[],'omitnan');
if isempty(max_vis_radius) || max_vis_radius <=0; max_vis_radius = 10; end
[sx,sy,sz] = sphere(20);
surf(sx*max_vis_radius*0.1, sy*max_vis_radius*0.1, sz*max_vis_radius*0.1, ...
    'FaceColor','none','EdgeColor',[0.8 0.8 0.8],'LineStyle',':'); % 小参考球
axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title(['初始设计 RCS (dBsm) - 平均: ', num2str(avg_rcs_init_dbsm, '%.2f'), ' dBsm']);
colorbar; % 显示颜色条
colormap('jet');
% 设置合理的颜色轴范围
caxis_min = max(-50, min_r - 5);
caxis_max = min(30, max_r + 5);
if caxis_min >= caxis_max; caxis_min = caxis_max - 10; end % Ensure valid range
caxis([caxis_min, caxis_max]);
view(135, 30); % 设置初始视角
rotate3d on;
axis tight;


% --- 5. 使用遗传算法优化 ---
disp(' ');
disp('开始使用遗传算法优化设计参数...');

% 5.1 定义目标函数 (Objective Function)
% 目标是最小化平均 RCS (线性值 m^2)
% 传递固定的参数 lambda, PHI, THETA 给目标函数
objectiveFunction = @(params) calculateAverageRCS(params, lambda, PHI, THETA);

% 5.2 定义优化变量的边界 (Bounds)
% [fuselageLength, maxFuselageWidth, wingSpan, wingSweepDeg, noseLengthRatio, tailHeight]
lb = [12, 2.0, 9,  45, 0.25, 1.0]; % 下界
ub = [20, 5.0, 14, 70, 0.45, 3.0]; % 上界
nvars = length(initial_params);  % 变量数量

% 5.3 设置遗传算法参数 (可选, 使用默认值或自定义)
options = optimoptions('ga', ...
    'PopulationSize', 60, ...       % 种群大小 (稍大)
    'MaxGenerations', 80, ...      % 最大迭代代数 (减少迭代，加速演示)
    'PlotFcn', {@gaplotbestf}, ... % 绘制最优适应度函数值
    'Display', 'iter', ...         % 显示迭代信息
    'UseParallel', false, ...      % 是否使用并行计算 (需要 Parallel Computing Toolbox)
    'ConstraintTolerance', 1e-4, ... % 约束容差
    'FunctionTolerance', 1e-4);     % 函数值容差

% 5.4 运行遗传算法
% 注意：这步可能需要较长时间
try
    % 检查 Global Optimization Toolbox 是否存在
    if ~license('test', 'GADS_Toolbox')
        error('globaloptim:ga:licenseFail', '运行遗传算法需要 Global Optimization Toolbox 授权。');
    end

    [optimal_params, min_avg_rcs_m2] = ga(objectiveFunction, nvars, [], [], [], [], lb, ub, [], options);

    % --- 6. 分析和可视化优化结果 ---
    disp(' ');
    disp('优化完成.');
    disp('最优设计参数:');
    fprintf('  机身长度: %.2f m\n', optimal_params(1));
    fprintf('  最大宽度: %.2f m\n', optimal_params(2));
    fprintf('  翼展:     %.2f m\n', optimal_params(3));
    fprintf('  后掠角:   %.2f deg\n', optimal_params(4));
    fprintf('  机头比例: %.2f\n', optimal_params(5));
    fprintf('  垂尾高度: %.2f m\n', optimal_params(6));

    min_avg_rcs_dbsm = 10*log10(min_avg_rcs_m2 + eps);
    disp(['优化后最小平均 RCS: ', num2str(min_avg_rcs_m2, '%.4f'), ' m^2 (', num2str(min_avg_rcs_dbsm, '%.2f'), ' dBsm)']);

    % 6.1 创建并可视化优化后的飞机模型
    [vertices_opt, faces_opt] = createStealthFighterGeometry(optimal_params);

    figure('Name', '优化后的隐身战斗机模型');
    h_patch_opt = patch('Vertices', vertices_opt, 'Faces', faces_opt, ...
          'FaceColor', [0.2 0.8 0.2], 'EdgeColor', 'k', 'FaceAlpha', 0.8); % 用绿色表示优化后
    axis equal; grid on; view(3);
    xlabel('X (m) - 机头方向'); ylabel('Y (m)'); zlabel('Z (m)');
    title('优化后的简化隐身战斗机模型');
    rotate3d on;

    % 6.2 计算并可视化优化后的 RCS 方向图
    disp('正在计算优化后设计的 RCS...');
    rcs_pattern_opt_m2 = zeros(size(PHI));
    h_wait_opt = waitbar(0, '正在计算优化后 RCS...');
    count_opt = 0;
    for i = 1:rows
        for j = 1:cols
            phi = PHI(i,j);
            theta = THETA(i,j);
            ux = cos(theta) * cos(phi);
            uy = cos(theta) * sin(phi);
            uz = sin(theta);
            radar_dir = [ux; uy; uz];
            rcs_pattern_opt_m2(i, j) = calculateFacetRCS(vertices_opt, faces_opt, radar_dir, lambda);
            count_opt = count_opt + 1;
            waitbar(count_opt / total_calcs, h_wait_opt);
        end
    end
    close(h_wait_opt);

    rcs_pattern_opt_dbsm = 10 * log10(rcs_pattern_opt_m2 + eps);
    avg_rcs_opt_dbsm = 10*log10(mean(rcs_pattern_opt_m2(:), 'omitnan')); % 重新计算确认

    figure('Name', '优化后设计 RCS 方向图 (3D)');
    max_r_opt = max(rcs_pattern_opt_dbsm(:), [], 'omitnan');
    min_r_opt = min(rcs_pattern_opt_dbsm(:), [], 'omitnan');
    if isinf(max_r_opt) || isnan(max_r_opt); max_r_opt = 10; end
    if isinf(min_r_opt) || isnan(min_r_opt); min_r_opt = -40; end

    rcs_radius_opt = max(0, rcs_pattern_opt_dbsm + vis_radius_offset) * vis_radius_scale;
    rcs_radius_opt(rcs_pattern_opt_dbsm < -20) = 1; % Thresholding

    X_rcs_opt = rcs_radius_opt .* cos(THETA) .* cos(PHI);
    Y_rcs_opt = rcs_radius_opt .* cos(THETA) .* sin(PHI);
    Z_rcs_opt = rcs_radius_opt .* sin(THETA);

    surf(X_rcs_opt, Y_rcs_opt, Z_rcs_opt, rcs_pattern_opt_dbsm, 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    hold on;
    max_vis_radius_opt = max(rcs_radius_opt(:),[],'omitnan');
     if isempty(max_vis_radius_opt) || max_vis_radius_opt <=0; max_vis_radius_opt = 10; end
    [sx,sy,sz] = sphere(20);
    surf(sx*max_vis_radius_opt*0.1, sy*max_vis_radius_opt*0.1, sz*max_vis_radius_opt*0.1, ...
        'FaceColor','none','EdgeColor',[0.8 0.8 0.8],'LineStyle',':');
    axis equal; grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title(['优化后设计 RCS (dBsm) - 平均: ', num2str(avg_rcs_opt_dbsm, '%.2f'), ' dBsm']);
    colorbar;
    colormap('jet');
    % 使用相同的颜色范围比较优化前后
    caxis_min_combined = max(-50, min(min_r, min_r_opt) - 5);
    caxis_max_combined = min(30, max(max_r, max_r_opt) + 5);
     if caxis_min_combined >= caxis_max_combined; caxis_min_combined = caxis_max_combined - 10; end
    caxis([caxis_min_combined, caxis_max_combined]);
    view(135, 30); % Use same view angle
    rotate3d on;
    axis tight;

    % 6.3 对比图 (例如，对比平均RCS)
    figure('Name', '优化效果对比');
    bar_data = [avg_rcs_init_dbsm, avg_rcs_opt_dbsm];
    bar_labels = {'初始设计', '优化后设计'};
    b = bar(bar_data);
    set(gca, 'xticklabel', bar_labels);
    ylabel('平均 RCS (dBsm)');
    title('遗传算法优化前后平均 RCS 对比');
    grid on;
    % 在柱状图上显示数值
    xtips = b.XEndPoints;
    ytips = b.YEndPoints;
    labels = string(num2str(bar_data', '%.2f'));
    text(xtips, ytips, labels, 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
    ylim([min(bar_data)*1.2 - 1, max(bar_data)*0.8 + 5]); % Adjust y-axis limits slightly

catch ME
    if strcmp(ME.identifier, 'globaloptim:ga:licenseFail') || contains(ME.message, 'Global Optimization Toolbox')
        disp(' ');
        disp('错误：需要 Global Optimization Toolbox 才能运行遗传算法优化部分。');
        disp('请确保已安装并获得授权。');
        disp('将跳过优化步骤，仅显示初始模型的计算和可视化结果。');
    elseif contains(ME.message, 'optimoptions') % Older MATLAB check
         disp(' ');
         disp('错误: 您的MATLAB版本可能不支持 optimoptions 的某些语法或 GA。');
         disp('请确保拥有 Global Optimization Toolbox。将跳过优化步骤。');
    else
        disp(' ');
        disp(['运行遗传算法时发生错误: ', ME.message]);
        disp('错误详情:');
        disp(ME.getReport);
        rethrow(ME); % Rethrow the error for more details if needed
    end
    % 如果没有工具箱或出错，确保后续代码不会因缺少 optimal_params 而失败
    optimal_params = initial_params; % 保持初始值
    min_avg_rcs_m2 = avg_rcs_init_m2;
    disp(' ');
    disp('优化步骤被跳过。');
end

disp(' ');
disp('程序执行完毕。');


% --- 辅助函数 ---

function [vertices, faces] = createStealthFighterGeometry(params)
% 根据参数创建简化的菱形翼身融合体几何模型 (修正版)
% params = [fuselageLength, maxFuselageWidth, wingSpan, wingSweepDeg, noseLengthRatio, tailHeight]

    len = params(1);
    max_w = params(2);
    span = params(3);
    sweep_deg = params(4);
    nose_ratio = params(5);
    tail_h = params(6);

    sweep_rad = deg2rad(sweep_deg);

    % --- 主要顶点计算 ---
    nose_len = len * nose_ratio;
    body_len = len * (1 - nose_ratio);

    nose_tip = [nose_len, 0, 0];                     % 1: 机头尖端
    wing_body_joint_fwd = [0, 0, 0];                 % 2: 机翼/机身前结合点 (坐标原点)

    % 假设机身最宽处在从原点向后 body_len * 0.4 的位置
    max_width_x = - body_len * 0.4;
    body_side_fwd_right = [0, max_w / 2 * 0.1, 0];     % 3: 机身前侧点 (稍微有点宽度) - 右
    body_side_maxw_right= [max_width_x, max_w / 2, 0]; % 5: 机身最宽处侧点 - 右

    wing_tip_y = span / 2;
    % 翼尖X坐标，基于后掠角和最宽处的机身点计算
    wing_tip_x = max_width_x - (wing_tip_y - max_w / 2) / tan(sweep_rad);
    wing_tip_right = [wing_tip_x, wing_tip_y, 0];      % 7: 翼尖 - 右

    fuselage_rear_tip = [-body_len, 0, 0];             % 9: 机身尾部尖端 (机翼后缘汇聚点)

    % 简化垂尾顶点 (两个倾斜面)
    tail_base_rear = fuselage_rear_tip;
    tail_top_rear = [fuselage_rear_tip(1) + body_len*0.1, 0, tail_h]; % 10: 垂尾后上点 (稍微靠前一点)
    tail_base_fwd_x = fuselage_rear_tip(1) + body_len*0.3;            % 垂尾前下点 X
    tail_base_fwd_y = max_w * 0.05;                                    % 垂尾前下点 Y (非常小的宽度)
    tail_top_fwd = [tail_base_fwd_x, 0, tail_h];                      % 11: 垂尾前上点

    tail_base_fwd_right = [tail_base_fwd_x, tail_base_fwd_y, 0];     % 12: 垂尾前下点 - 右

    % --- 定义顶部顶点列表 (Top Surface Vertices) ---
    top_vertices = [
        nose_tip;                                       % 1: Nose Tip
        wing_body_joint_fwd;                            % 2: Body/Wing Center Fwd
        body_side_fwd_right;                            % 3: Body Side Fwd (Right)
        [body_side_fwd_right(1), -body_side_fwd_right(2), body_side_fwd_right(3)]; % 4: Body Side Fwd (Left)
        body_side_maxw_right;                           % 5: Body Side Max Width (Right)
        [body_side_maxw_right(1), -body_side_maxw_right(2), body_side_maxw_right(3)]; % 6: Body Side Max Width (Left)
        wing_tip_right;                                 % 7: Wing Tip (Right)
        [wing_tip_right(1), -wing_tip_right(2), wing_tip_right(3)]; % 8: Wing Tip (Left)
        fuselage_rear_tip;                              % 9: Fuselage Rear Tip Center
        tail_top_rear;                                  % 10: Tail Top Rear
        tail_top_fwd;                                   % 11: Tail Top Fwd
        tail_base_fwd_right;                            % 12: Tail Base Fwd (Right)
        [tail_base_fwd_right(1), -tail_base_fwd_right(2), tail_base_fwd_right(3)]; % 13: Tail Base Fwd (Left)
    ];
    num_top_vertices = size(top_vertices, 1); % Should be 13

    % --- 定义底部顶点列表 (Bottom Surface Vertices) ---
    % 镜像顶部顶点 1 到 9, 12, 13 (不镜像垂尾顶部 10, 11)
    indices_to_mirror = [1:9, 12, 13];
    bottom_vertices = top_vertices(indices_to_mirror, :) .* [1, 1, -1];

    % --- 合并顶点 ---
    vertices = [top_vertices; bottom_vertices];

    % --- 定义面列表 (Faces) ---
    % 建立从顶部索引到对应底部索引的映射
    % 底部顶点从 num_top_vertices + 1 开始
    map_top_to_bottom_idx = containers.Map('KeyType','int32','ValueType','int32');
    for k = 1:length(indices_to_mirror)
        top_idx = indices_to_mirror(k);
        bottom_idx = num_top_vertices + k;
        map_top_to_bottom_idx(top_idx) = bottom_idx;
    end

    % 顶部面片 (顶点顺序尽量保证法线朝上或朝外)
    faces_top = [
        1, 3, 2;        % Nose Right Top Front
        1, 2, 4;        % Nose Left Top Front
        2, 3, 5;        % Body Right Top Mid Front
        2, 5, 9;        % Body Right Top Mid Rear (removed intermediate point)
        2, 6, 4;        % Body Left Top Mid Front
        2, 9, 6;        % Body Left Top Mid Rear (removed intermediate point)
        3, 7, 5;        % Wing Right Top Front/LERX (check normal dir)
        5, 7, 9;        % Wing Right Top Rear (check normal dir)
        4, 8, 6;        % Wing Left Top Front/LERX (check normal dir)
        6, 8, 9;        % Wing Left Top Rear (check normal dir)

        % Tail Base Top (connecting wing/body rear to tail base front)
        5, 12, 9;       % Right side
        6, 9, 13;       % Left side

        % Tail Fins (Ensure outward normals)
        11, 10, 12;     % Tail Right Outer Face (Top fwd, Top rear, Base fwd R) -> Normal should point right-up
        10, 9, 12;      % Tail Right Inner Face (Top rear, Base rear, Base fwd R) -> Normal should point left-up
        11, 13, 10;     % Tail Left Outer Face (Top fwd, Base fwd L, Top rear) -> Normal should point left-up
        10, 13, 9;      % Tail Left Inner Face (Top rear, Base fwd L, Base rear) -> Normal should point right-up
    ];

    % 底部面片 (镜像顶部面片，并反转顶点顺序以使法线朝下)
    faces_bottom = [
        map_top_to_bottom_idx(1), map_top_to_bottom_idx(2), map_top_to_bottom_idx(3); % Mirror 1,3,2 -> 1,2,3 bottom
        map_top_to_bottom_idx(1), map_top_to_bottom_idx(4), map_top_to_bottom_idx(2); % Mirror 1,2,4 -> 1,4,2 bottom
        map_top_to_bottom_idx(2), map_top_to_bottom_idx(5), map_top_to_bottom_idx(3); % Mirror 2,3,5 -> 2,5,3 bottom
        map_top_to_bottom_idx(2), map_top_to_bottom_idx(9), map_top_to_bottom_idx(5); % Mirror 2,5,9 -> 2,9,5 bottom
        map_top_to_bottom_idx(2), map_top_to_bottom_idx(4), map_top_to_bottom_idx(6); % Mirror 2,6,4 -> 2,4,6 bottom
        map_top_to_bottom_idx(2), map_top_to_bottom_idx(6), map_top_to_bottom_idx(9); % Mirror 2,9,6 -> 2,6,9 bottom
        map_top_to_bottom_idx(3), map_top_to_bottom_idx(5), map_top_to_bottom_idx(7); % Mirror 3,7,5 -> 3,5,7 bottom
        map_top_to_bottom_idx(5), map_top_to_bottom_idx(9), map_top_to_bottom_idx(7); % Mirror 5,7,9 -> 5,9,7 bottom
        map_top_to_bottom_idx(4), map_top_to_bottom_idx(6), map_top_to_bottom_idx(8); % Mirror 4,8,6 -> 4,6,8 bottom
        map_top_to_bottom_idx(6), map_top_to_bottom_idx(9), map_top_to_bottom_idx(8); % Mirror 6,8,9 -> 6,9,8 bottom
        map_top_to_bottom_idx(5), map_top_to_bottom_idx(9), map_top_to_bottom_idx(12); % Mirror 5,12,9 -> 5,9,12 bottom
        map_top_to_bottom_idx(6), map_top_to_bottom_idx(13), map_top_to_bottom_idx(9); % Mirror 6,9,13 -> 6,13,9 bottom
    ];

    % 合并面列表
    faces = [faces_top; faces_bottom];

    % 可选：添加封闭尾部和翼尖的面 (如果需要完全封闭的模型)
    % faces_closure = [ ... ];
    % faces = [faces; faces_closure];
end


function rcs_total_m2 = calculateFacetRCS(vertices, faces, radar_dir, lambda)
% 简化的面元 RCS 计算 (物理光学近似 - 镜面反射贡献)
% Input:
%   vertices: Nv x 3 顶点坐标矩阵
%   faces:    Nf x 3 面索引矩阵 (三角面)
%   radar_dir: 3x1 雷达视线方向矢量 (从雷达指向目标, 单位矢量)
%   lambda:   波长 (m)
% Output:
%   rcs_total_m2: 该方向的总 RCS (m^2) - 非相干叠加

    rcs_total_m2 = 0;
    num_faces = size(faces, 1);
    radar_dir = radar_dir(:) / norm(radar_dir); % 确保是单位列向量

    for i = 1:num_faces
        % 获取当前面的顶点坐标
        v_indices = faces(i, :);
        % Handle potential NaN or Inf vertex indices if geometry creation failed
        if any(isnan(v_indices)) || any(isinf(v_indices)) || any(v_indices <= 0) || any(v_indices > size(vertices, 1))
            %warning('Skipping face %d due to invalid vertex indices.', i);
            continue;
        end
        p1 = vertices(v_indices(1), :)'; % 转为列向量
        p2 = vertices(v_indices(2), :)';
        p3 = vertices(v_indices(3), :)';

        % 检查顶点是否有效 (非 NaN/Inf)
        if any(isnan([p1; p2; p3])) || any(isinf([p1; p2; p3]))
            %warning('Skipping face %d due to invalid vertex coordinates.', i);
            continue; % Skip if vertices are invalid
        end

        % 计算面元的法向量 (需要保证指向外) 和面积
        edge1 = p2 - p1;
        edge2 = p3 - p1;
        normal_vec = cross(edge1, edge2);
        face_area = 0.5 * norm(normal_vec);

        % 忽略面积过小或无效的面 (例如，共线点)
        if face_area < 1e-9 || isnan(face_area) || isinf(face_area)
            continue;
        end

        normal_vec = normal_vec / (2 * face_area); % 单位法向量

        % --- 简化 RCS 计算逻辑 ---
        % 物理光学 (PO) 近似，主要考虑镜面反射贡献
        % 入射波方向 k_inc = -radar_dir
        % 面法线 n = normal_vec
        % theta_inc 是入射方向与法线的夹角
        cos_theta_inc = dot(normal_vec, -radar_dir);

        % 仅当面朝向雷达时计算 (cos > 0)
        if cos_theta_inc > 1e-6
            % 简化 PO 公式: RCS_facet = (4 * pi * Area^2 / lambda^2) * cos^2(theta_inc)
            % 注意：这是高度简化的公式，忽略了相位、边缘效应等。
            % 实际PO积分更复杂，但这个形式在高频镜面反射时有一定代表性。
            rcs_facet = (4 * pi * face_area^2 / lambda^2) * (cos_theta_inc^2);

            % 非相干叠加各面元贡献 (直接加功率)
            rcs_total_m2 = rcs_total_m2 + rcs_facet;
        end
    end

    % 添加一个小的基底值，避免结果为绝对零或负无穷dB
    rcs_total_m2 = max(rcs_total_m2, 1e-10);
end


function avg_rcs_m2 = calculateAverageRCS(params, lambda, PHI_grid, THETA_grid)
% GA 目标函数：计算给定参数下的平均 RCS (线性 m^2)

    % 1. 根据输入参数创建几何模型
    try
        [vertices, faces] = createStealthFighterGeometry(params);
        % 增加一个检查，确保生成的顶点有效
        if any(isnan(vertices(:))) || any(isinf(vertices(:)))
             error('Generated geometry contains NaN/Inf vertices.');
        end
    catch ME
        %fprintf('警告: 参数 [%s] 无法创建有效几何模型: %s\n', num2str(params), ME.message);
        avg_rcs_m2 = 1e10; % 返回一个很大的惩罚值
        return;
    end

    % 2. 计算多个方向上的 RCS
    rcs_pattern_m2 = zeros(size(PHI_grid));
    [rows, cols] = size(PHI_grid);

    % --- 使用全部角度计算 (更准确但慢) ---
    num_calcs = numel(PHI_grid);
    temp_rcs_vals = zeros(1, num_calcs); % Store in a vector first
    calc_idx = 0;

    for i = 1:rows
       for j = 1:cols
           calc_idx = calc_idx + 1;
           phi = PHI_grid(i,j);
           theta = THETA_grid(i,j);
           % 避免极点处的重复计算或潜在问题 (theta = +/- 90 deg)
           if abs(abs(theta) - pi/2) < 1e-6
               ux = 0; uy = 0; uz = sin(theta);
           else
               ux = cos(theta) * cos(phi);
               uy = cos(theta) * sin(phi);
               uz = sin(theta);
           end
           radar_dir = [ux; uy; uz];
           temp_rcs_vals(calc_idx) = calculateFacetRCS(vertices, faces, radar_dir, lambda);
       end
    end

    % 3. 计算平均 RCS (线性值)，忽略 NaN 或 Inf 值
    avg_rcs_m2 = mean(temp_rcs_vals, 'omitnan');

    % 检查平均值是否有效，如果所有计算都失败，则返回惩罚值
    if isnan(avg_rcs_m2) || isinf(avg_rcs_m2)
        avg_rcs_m2 = 1e10; % Penalty for invalid average RCS
    end

    % 可选：增加惩罚项，例如对于长宽比过于极端或不符合实际的形状
    fuselageLength = params(1);
    maxFuselageWidth = params(2);
    wingSpan = params(3);
    aspect_ratio_body = fuselageLength / maxFuselageWidth;
    aspect_ratio_wing = wingSpan*wingSpan / (0.5 * wingSpan * fuselageLength*(1-params(5))); % 简化翼面积估算

    penalty = 0;
    if aspect_ratio_body < 3 || aspect_ratio_body > 8 % 不希望机身太胖或太细长
        penalty = penalty + (abs(aspect_ratio_body - 5))^2; % Quadratic penalty away from desired ratio ~5
    end
    if aspect_ratio_wing < 1.5 || aspect_ratio_wing > 5 % 不希望展弦比太小或太大
         penalty = penalty + (abs(aspect_ratio_wing - 3))^2; % Quadratic penalty away from desired ratio ~3
    end

    % 将惩罚值（放大后）加到目标函数上
    avg_rcs_m2 = avg_rcs_m2 * (1 + penalty * 0.1); % Scale penalty influence

end