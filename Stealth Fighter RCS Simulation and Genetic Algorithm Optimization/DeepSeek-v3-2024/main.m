%% 隐身战斗机RCS建模与优化
clc; clear; close all;

%% 参数设置
% 战斗机基本参数
params.wing_span = 10;      % 翼展(m)
params.fuselage_length = 15; % 机身长度(m)
params.nose_angle = 30;      % 机头锥角(度)
params.wing_sweep = 45;      % 机翼后掠角(度)
params.tail_angle = 45;      % 尾翼角度(度)
params.surface_smoothness = 0.8; % 表面平滑度(0-1)

% 雷达参数
radar.freq = 10e9;          % 雷达频率(Hz)
radar.wavelength = 3e8/radar.freq; % 波长(m)

% 遗传算法参数
ga_params.pop_size = 20;     % 种群大小
ga_params.max_gen = 30;      % 最大代数
ga_params.mutation_rate = 0.1; % 变异率

%% 初始战斗机建模与RCS计算
% 生成战斗机网格
[V, F] = generate_stealth_fighter(params);

% 计算全方位RCS
[azimuth, elevation, RCS] = calculate_rcs(V, F, radar);

% 显示初始设计
display_results(V, F, azimuth, elevation, RCS, 'Initial Stealth Fighter Design');

%% 遗传算法优化
fprintf('\nStarting Genetic Algorithm Optimization...\n');
best_params = ga_optimization(@(p) fitness_function(p, radar), params, ga_params);

%% 优化后结果
% 生成优化后的战斗机网格
[V_opt, F_opt] = generate_stealth_fighter(best_params);

% 计算优化后全方位RCS
[azimuth_opt, elevation_opt, RCS_opt] = calculate_rcs(V_opt, F_opt, radar);

% 显示优化结果
display_results(V_opt, F_opt, azimuth_opt, elevation_opt, RCS_opt, 'Optimized Stealth Fighter Design');

% 比较优化前后RCS
compare_results(azimuth, elevation, RCS, azimuth_opt, elevation_opt, RCS_opt);

%% 战斗机生成函数
function [V, F] = generate_stealth_fighter(params)
    % 生成隐身战斗机的基本形状
    
    % 机身(扁椭球体)
    fuselage_resolution = 20;
    [x, y, z] = ellipsoid(0, 0, 0, params.fuselage_length/2, params.wing_span/4, params.wing_span/6, fuselage_resolution);
    z = z * 0.8; % 使机身更扁平
    
    % 机头(锥形)
    nose_length = params.fuselage_length/3;
    nose_radius = params.wing_span/4;
    [xn, yn, zn] = cylinder(linspace(nose_radius, 0.1, 10), fuselage_resolution);
    zn = zn * nose_length;
    xn = xn + params.fuselage_length/2;
    
    % 机翼(后掠翼)
    wing_resolution = 15;
    wing_chord = params.fuselage_length/3;
    [xw, yw, zw] = meshgrid(...
        linspace(-wing_chord/2, wing_chord/2, wing_resolution),...
        linspace(0, params.wing_span/2, wing_resolution),...
        linspace(-0.1, 0.1, 3));
    
    % 应用后掠角
    sweep_angle = params.wing_sweep * pi/180;
    xw = xw + yw * tan(sweep_angle);
    
    % 尾翼
    tail_resolution = 10;
    tail_chord = params.fuselage_length/4;
    [xt, yt, zt] = meshgrid(...
        linspace(-tail_chord/2, tail_chord/2, tail_resolution),...
        linspace(-params.wing_span/6, params.wing_span/6, tail_resolution),...
        linspace(0, params.fuselage_length/5, 3));
    
    % 应用尾翼角度
    tail_angle = params.tail_angle * pi/180;
    xt = xt - params.fuselage_length/2;
    zt = zt + yt * tan(tail_angle);
    
    % 合并所有部件
    V_fuselage = [x(:), y(:), z(:)];
    V_nose = [xn(:), yn(:), zn(:)];
    V_wing = [xw(:), yw(:), zw(:)];
    V_tail = [xt(:), yt(:), zt(:)];
    
    % 创建三角面片
    F_fuselage = delaunayTriangulation(x(:), y(:), z(:));
    F_nose = delaunayTriangulation(xn(:), yn(:), zn(:));
    
    % 简化表示 - 实际应用中需要更精确的网格生成
    V = [V_fuselage; V_nose; V_wing; V_tail];
    F = [F_fuselage.ConnectivityList; F_nose.ConnectivityList + size(V_fuselage,1)];
    
    % 应用表面平滑
    if params.surface_smoothness > 0
        V = smooth_surface(V, F, params.surface_smoothness);
    end
end

%% 表面平滑函数
function V_smooth = smooth_surface(V, F, alpha)
    % 简单的表面平滑算法
    V_smooth = V;
    for i = 1:size(V,1)
        % 找到相邻顶点
        [row, ~] = find(F == i);
        neighbors = unique(F(row, :));
        neighbors = neighbors(neighbors ~= i);
        
        if ~isempty(neighbors)
            % 计算相邻顶点平均值
            neighbor_mean = mean(V(neighbors, :));
            % 应用平滑
            V_smooth(i, :) = (1-alpha)*V(i, :) + alpha*neighbor_mean;
        end
    end
end

%% RCS计算函数
function [azimuth, elevation, RCS] = calculate_rcs(V, F, radar)
    % 计算全方位RCS(简化模型)
    
    % 方位角和仰角范围
    azimuth = linspace(0, 360, 36);    % 每10度一个点
    elevation = linspace(-90, 90, 19); % 每10度一个点
    
    RCS = zeros(length(elevation), length(azimuth));
    
    % 计算每个方向的RCS
    for i = 1:length(elevation)
        for j = 1:length(azimuth)
            % 计算观察方向矢量
            el = elevation(i) * pi/180;
            az = azimuth(j) * pi/180;
            
            k = [cos(el)*cos(az); cos(el)*sin(az); sin(el)]; % 波矢量
            
            % 简化RCS计算(物理光学近似)
            RCS(i,j) = compute_po_rcs(V, F, k, radar.wavelength);
        end
    end
end

%% 物理光学法RCS计算(简化版)
function rcs = compute_po_rcs(V, F, k, wavelength)
    % 简化的物理光学法RCS计算
    
    total_rcs = 0;
    k = k/norm(k); % 归一化
    
    for i = 1:size(F,1)
        % 获取三角形顶点
        v1 = V(F(i,1),:);
        v2 = V(F(i,2),:);
        v3 = V(F(i,3),:);
        
        % 计算面法向量
        edge1 = v2 - v1;
        edge2 = v3 - v1;
        normal = cross(edge1, edge2);
        area = norm(normal)/2;
        normal = normal/norm(normal);
        
        % 只考虑朝向雷达的面
        if dot(normal, k) < 0
            % 计算相位中心
            phase_center = (v1 + v2 + v3)/3;
            
            % 计算散射场(简化模型)
            reflection_coeff = 0.5; % 简化反射系数
            phase = exp(-1i * 4 * pi * dot(k, phase_center) / wavelength);
            scattered_field = reflection_coeff * area * phase;
            
            % 累加RCS贡献
            total_rcs = total_rcs + abs(scattered_field)^2;
        end
    end
    
    % 转换为dBsm
    rcs = 10*log10(total_rcs + 1e-6); % 避免log(0)
end

%% 适应度函数(用于遗传算法)
function fitness = fitness_function(params, radar)
    % 生成战斗机模型
    [V, F] = generate_stealth_fighter(params);
    
    % 计算RCS(简化版，只计算关键方向)
    key_azimuth = [0, 45, 90, 135, 180, 225, 270, 315];
    key_elevation = [-45, 0, 45];
    
    total_rcs = 0;
    for az = key_azimuth
        for el = key_elevation
            k = [cosd(el)*cosd(az); cosd(el)*sind(az); sind(el)];
            rcs = compute_po_rcs(V, F, k, radar.wavelength);
            total_rcs = total_rcs + rcs;
        end
    end
    
    % 适应度是RCS的负值(我们希望最小化RCS)
    fitness = -total_rcs;
end

%% 遗传算法优化函数
function best_params = ga_optimization(fitness_func, init_params, ga_params)
    % 参数边界
    lb = struct2array(init_params) * 0.7; % 下限
    ub = struct2array(init_params) * 1.3; % 上限
    
    % 确保平滑度在0-1之间
    lb(end) = 0;
    ub(end) = 1;
    
    param_names = fieldnames(init_params);
    num_params = length(param_names);
    
    % 初始化种群
    population = zeros(ga_params.pop_size, num_params);
    for i = 1:ga_params.pop_size
        population(i,:) = lb + (ub-lb).*rand(1,num_params);
    end
    
    % 存储每代最佳适应度
    best_fitness_history = zeros(ga_params.max_gen, 1);
    
    % 遗传算法主循环
    for gen = 1:ga_params.max_gen
        % 评估适应度
        fitness = zeros(ga_params.pop_size, 1);
        for i = 1:ga_params.pop_size
            % 将数组转换为结构体
            individual = cell2struct(num2cell(population(i,:)), param_names, 2);
            fitness(i) = fitness_func(individual);
        end
        
        % 记录最佳个体
        [best_fitness, best_idx] = max(fitness);
        best_fitness_history(gen) = best_fitness;
        best_individual = population(best_idx,:);
        
        fprintf('Generation %d: Best Fitness = %.2f\n', gen, best_fitness);
        
        % 选择(锦标赛选择)
        new_population = zeros(size(population));
        for i = 1:ga_params.pop_size
            % 随机选择两个个体
            candidates = randperm(ga_params.pop_size, 2);
            [~, winner] = max(fitness(candidates));
            new_population(i,:) = population(candidates(winner),:);
        end
        
        % 交叉(均匀交叉)
        for i = 1:2:ga_params.pop_size-1
            if rand() < 0.8 % 交叉概率
                mask = rand(1,num_params) > 0.5;
                temp = new_population(i,mask);
                new_population(i,mask) = new_population(i+1,mask);
                new_population(i+1,mask) = temp;
            end
        end
        
        % 变异(高斯变异)
        for i = 1:ga_params.pop_size
            if rand() < ga_params.mutation_rate
                mutation = randn(1,num_params) .* (ub-lb)/10;
                new_population(i,:) = new_population(i,:) + mutation;
                % 确保在边界内
                new_population(i,:) = max(lb, min(ub, new_population(i,:)));
            end
        end
        
        % 保留最佳个体(精英保留)
        new_population(1,:) = best_individual;
        
        population = new_population;
    end
    
    % 返回最佳参数
    best_params = cell2struct(num2cell(best_individual), param_names, 2);
    
    % 绘制适应度曲线
    figure;
    plot(1:ga_params.max_gen, best_fitness_history, 'LineWidth', 2);
    xlabel('Generation');
    ylabel('Best Fitness (-RCS in dBsm)');
    title('Genetic Algorithm Optimization Progress');
    grid on;
end

%% 结果显示函数
function display_results(V, F, azimuth, elevation, RCS, title_str)
    % 显示3D模型
    figure('Name', title_str, 'Position', [100, 100, 1200, 500]);
    subplot(1,2,1);
    trisurf(F, V(:,1), V(:,2), V(:,3), 'FaceColor', [0.8 0.8 1.0], 'EdgeColor', 'none');
    axis equal; grid on;
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    title(['3D Model: ' title_str]);
    light('Position', [1 0 0], 'Style', 'infinite');
    lighting gouraud;
    material dull;
    view(3);
    
    % 显示RCS极坐标图
    subplot(1,2,2);
    [AZ, EL] = meshgrid(azimuth*pi/180, elevation*pi/180);
    [X, Y, Z] = sph2cart(AZ, EL, RCS - min(RCS(:)) + 1); % 避免负值
    
    surf(X, Y, Z, RCS, 'EdgeColor', 'none');
    axis equal; grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('RCS Pattern (dBsm)');
    colorbar;
    colormap jet;
    
    % 显示平均RCS
    avg_rcs = mean(RCS(:));
    fprintf('%s - Average RCS: %.2f dBsm\n', title_str, avg_rcs);
end

%% 结果比较函数
function compare_results(az1, el1, rcs1, az2, el2, rcs2)
    % 比较优化前后的RCS
    
    % 计算平均RCS
    avg_rcs1 = mean(rcs1(:));
    avg_rcs2 = mean(rcs2(:));
    
    % 计算RCS减少百分比
    rcs_reduction = (avg_rcs1 - avg_rcs2) / abs(avg_rcs1) * 100;
    
    fprintf('\nOptimization Results:\n');
    fprintf('Initial Average RCS: %.2f dBsm\n', avg_rcs1);
    fprintf('Optimized Average RCS: %.2f dBsm\n', avg_rcs2);
    fprintf('RCS Reduction: %.1f%%\n', rcs_reduction);
    
    % 绘制RCS比较图
    figure('Name', 'RCS Comparison', 'Position', [100, 100, 1000, 400]);
    
    % 方位角切面(elevation=0)
    [~, zero_el_idx] = min(abs(el1));
    subplot(1,2,1);
    plot(az1, rcs1(zero_el_idx,:), 'b', 'LineWidth', 2); hold on;
    plot(az2, rcs2(zero_el_idx,:), 'r', 'LineWidth', 2);
    xlabel('Azimuth Angle (deg)');
    ylabel('RCS (dBsm)');
    title('RCS at Zero Elevation');
    legend('Initial', 'Optimized');
    grid on;
    
    % 俯仰角切面(azimuth=0)
    [~, zero_az_idx] = min(abs(az1));
    subplot(1,2,2);
    plot(el1, rcs1(:,zero_az_idx), 'b', 'LineWidth', 2); hold on;
    plot(el2, rcs2(:,zero_az_idx), 'r', 'LineWidth', 2);
    xlabel('Elevation Angle (deg)');
    ylabel('RCS (dBsm)');
    title('RCS at Zero Azimuth');
    legend('Initial', 'Optimized');
    grid on;
    
    % 绘制3D RCS比较
    figure('Name', '3D RCS Comparison');
    subplot(1,2,1);
    [AZ, EL] = meshgrid(az1*pi/180, el1*pi/180);
    [X, Y, Z] = sph2cart(AZ, EL, rcs1 - min(rcs1(:)) + 1);
    surf(X, Y, Z, rcs1, 'EdgeColor', 'none');
    title('Initial RCS Pattern');
    axis equal; colorbar; colormap jet;
    
    subplot(1,2,2);
    [AZ, EL] = meshgrid(az2*pi/180, el2*pi/180);
    [X, Y, Z] = sph2cart(AZ, EL, rcs2 - min(rcs2(:)) + 1);
    surf(X, Y, Z, rcs2, 'EdgeColor', 'none');
    title('Optimized RCS Pattern');
    axis equal; colorbar; colormap jet;
end