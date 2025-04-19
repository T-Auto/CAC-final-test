% 隐身战斗机RCS建模与优化程序
% 该程序实现：
% 1. 使用几何模型构建简化的隐身战斗机
% 2. 计算不同方位角和俯仰角的RCS
% 3. 使用遗传算法优化战斗机设计参数以最小化RCS

%% 主程序
clear all;
close all;
clc;

% 初始设计参数
design_params = struct(...
    'length', 20,... % 飞机长度(m)
    'width', 15,... % 机翼展开宽度(m)
    'height', 4,... % 飞机高度(m)
    'nose_angle', 40,... % 机头角度(度)
    'wing_sweep', 45,... % 机翼后掠角(度)
    'tail_angle', 35); % 尾部角度(度)

% 显示初始模型
disp('初始战斗机模型:');
fighter = createFighterModel(design_params);
visualizeFighter(fighter, '初始隐身战斗机模型');

% 计算初始RCS
[init_theta, init_phi, init_rcs] = calculateRCS(fighter);

% 显示初始RCS分布
visualizeRCS(init_theta, init_phi, init_rcs, '初始设计RCS分布');
fprintf('初始设计平均RCS: %.4f m²\n', mean(init_rcs(:)));

% 使用遗传算法优化设计
disp('开始使用遗传算法优化设计...');
optimized_params = optimizeDesign(design_params);

% 显示优化后的模型
disp('优化后的战斗机模型:');
optimized_fighter = createFighterModel(optimized_params);
visualizeFighter(optimized_fighter, '优化后的隐身战斗机模型');

% 计算优化后的RCS
[opt_theta, opt_phi, opt_rcs] = calculateRCS(optimized_fighter);

% 显示优化后的RCS分布
visualizeRCS(opt_theta, opt_phi, opt_rcs, '优化设计RCS分布');
fprintf('优化设计平均RCS: %.4f m²\n', mean(opt_rcs(:)));

% 对比优化前后的RCS
compareRCS(init_theta, init_phi, init_rcs, opt_theta, opt_phi, opt_rcs);

% 输出优化结果
displayOptimizationResults(design_params, optimized_params);

%% 创建战斗机几何模型函数
function fighter = createFighterModel(params)
    % 根据设计参数创建隐身战斗机的几何模型
    
    % 提取参数
    L = params.length;
    W = params.width;
    H = params.height;
    nose_angle = params.nose_angle * pi/180;  % 转换为弧度
    wing_sweep = params.wing_sweep * pi/180;  % 转换为弧度
    tail_angle = params.tail_angle * pi/180;  % 转换为弧度
    
    % 创建机身点
    n_points = 30;
    
    % 机头部分（使用锥形）
    nose_length = L * 0.3;
    nose_x = linspace(0, nose_length, n_points);
    nose_r = nose_x * tan(nose_angle/2);
    
    % 机身主体部分
    body_length = L * 0.5;
    body_x = linspace(nose_length, nose_length + body_length, n_points);
    body_width = W * 0.2;
    body_height = H;
    
    % 尾部
    tail_length = L * 0.2;
    tail_x = linspace(nose_length + body_length, L, n_points);
    tail_r = linspace(body_width, 0, n_points);
    
    % 机翼
    wing_root_x = nose_length + body_length * 0.3;
    wing_tip_x = wing_root_x + W/2 * tan(wing_sweep);
    wing_length = W/2;
    
    % 组装fighter结构体
    fighter = struct();
    fighter.params = params;
    fighter.nose_x = nose_x;
    fighter.nose_r = nose_r;
    fighter.body_x = body_x;
    fighter.body_width = body_width;
    fighter.body_height = body_height;
    fighter.tail_x = tail_x;
    fighter.tail_r = tail_r;
    fighter.wing_root_x = wing_root_x;
    fighter.wing_tip_x = wing_tip_x;
    fighter.wing_length = wing_length;
    fighter.wing_sweep = wing_sweep;
    fighter.L = L;
    fighter.W = W;
    fighter.H = H;
end

%% 可视化战斗机模型
function visualizeFighter(fighter, title_text)
    figure;
    
    % 绘制机身
    [X, Y, Z] = cylinder(fighter.nose_r);
    X = X * 0.5;
    Z = Z * 0.5;
    X = X + repmat(fighter.nose_x', 1, size(X, 2));
    surf(X, Y * fighter.body_width, Z * fighter.body_height, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
    hold on;
    
    % 绘制机身主体
    [X, Y, Z] = cylinder(ones(size(fighter.body_x)));
    X = repmat(fighter.body_x', 1, size(X, 2));
    surf(X, Y * fighter.body_width, Z * fighter.body_height, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
    
    % 绘制尾部
    [X, Y, Z] = cylinder(fighter.tail_r);
    X = repmat(fighter.tail_x', 1, size(X, 2));
    surf(X, Y * 1, Z * fighter.body_height, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
    
    % 绘制机翼
    wing_x_left = [fighter.wing_root_x, fighter.wing_tip_x, fighter.wing_tip_x, fighter.wing_root_x];
    wing_y_left = [0, -fighter.wing_length, -fighter.wing_length, 0];
    wing_z_left = [0, 0, 0, 0] + fighter.body_height * 0.3;
    
    wing_x_right = [fighter.wing_root_x, fighter.wing_tip_x, fighter.wing_tip_x, fighter.wing_root_x];
    wing_y_right = [0, fighter.wing_length, fighter.wing_length, 0];
    wing_z_right = [0, 0, 0, 0] + fighter.body_height * 0.3;
    
    patch(wing_x_left, wing_y_left, wing_z_left, 'red', 'FaceAlpha', 0.8);
    patch(wing_x_right, wing_y_right, wing_z_right, 'red', 'FaceAlpha', 0.8);
    
    % 绘制垂直尾翼
    vtail_x = [fighter.L * 0.7, fighter.L * 0.9, fighter.L * 0.75, fighter.L * 0.7];
    vtail_y = [0, 0, 0, 0];
    vtail_z = [fighter.H * 0.5, fighter.H * 0.5, fighter.H * 1.2, fighter.H * 0.5];
    
    patch(vtail_x, vtail_y, vtail_z, 'green', 'FaceAlpha', 0.8);
    
    % 设置图形属性
    axis equal;
    grid on;
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    title(title_text);
    colormap('jet');
    view(30, 30);
    
    % 添加一个隐形战斗机的轮廓线
    plot3([0, fighter.L], [0, 0], [fighter.H/2, fighter.H/2], 'k--', 'LineWidth', 1);
    
    % 显示设计参数
    text(fighter.L/2, -fighter.W/2, fighter.H*1.5, ...
        sprintf('设计参数:\n长度: %.1fm\n宽度: %.1fm\n高度: %.1fm\n机头角度: %.1f°\n后掠角: %.1f°\n尾部角度: %.1f°', ...
        fighter.params.length, fighter.params.width, fighter.params.height, ...
        fighter.params.nose_angle, fighter.params.wing_sweep, ...
        fighter.params.tail_angle), 'FontSize', 8);
    
    hold off;
end

%% 计算RCS函数
function [theta, phi, rcs] = calculateRCS(fighter)
    % 计算不同方位角和俯仰角的RCS
    
    % 设置角度分辨率
    n_theta = 36;  % 方位角分辨率
    n_phi = 18;    % 俯仰角分辨率
    
    theta = linspace(0, 2*pi, n_theta);  % 方位角 (0-360度)
    phi = linspace(-pi/2, pi/2, n_phi);  % 俯仰角 (-90到90度)
    [THETA, PHI] = meshgrid(theta, phi);
    
    % 初始化RCS
    rcs = zeros(size(THETA));
    
    % 计算RCS (使用简化物理光学模型)
    for i = 1:n_phi
        for j = 1:n_theta
            % 当前观察角度
            current_theta = theta(j);
            current_phi = phi(i);
            
            % 根据角度计算RCS (简化模型)
            % 这里使用的是简化的物理模型，实际中需要更复杂的计算
            
            % 机头的贡献 (与机头角度和观察角度有关)
            nose_contrib = calculateNoseRCS(fighter, current_theta, current_phi);
            
            % 机翼的贡献
            wing_contrib = calculateWingRCS(fighter, current_theta, current_phi);
            
            % 机身的贡献
            body_contrib = calculateBodyRCS(fighter, current_theta, current_phi);
            
            % 总RCS (简单相加，实际中可能需要考虑相位)
            rcs(i, j) = nose_contrib + wing_contrib + body_contrib;
        end
    end
    
    % 添加一些随机噪声以模拟实际测量
    rcs = rcs + 0.1 * rand(size(rcs)) .* rcs;
    
    % 确保RCS为非负值
    rcs = max(rcs, 0.001);  % 最小RCS设为0.001平方米
end

%% 计算机头RCS的辅助函数
function rcs = calculateNoseRCS(fighter, theta, phi)
    % 计算机头在给定角度的RCS贡献
    
    % 从正面看，RCS主要受机头角度影响
    nose_angle = fighter.params.nose_angle * pi/180;
    
    % 根据观察角度计算有效角度
    % 正面观察时RCS最小
    head_on_factor = cos(theta)^2 * cos(phi)^2;
    
    % 机头角度越小，RCS越小
    angle_factor = sin(nose_angle)^2;
    
    % 基础RCS值
    base_rcs = 0.5;
    
    % 计算机头RCS
    rcs = base_rcs * angle_factor * (1 + 5 * head_on_factor);
    
    % 随角度调整
    if abs(theta) < 0.1 || abs(theta - 2*pi) < 0.1
        % 正面入射时RCS最小
        rcs = rcs * 0.2;
    end
end

%% 计算机翼RCS的辅助函数
function rcs = calculateWingRCS(fighter, theta, phi)
    % 计算机翼在给定角度的RCS贡献
    
    % 提取参数
    wing_sweep = fighter.params.wing_sweep * pi/180;
    
    % 机翼后掠角效应
    % 当观察角度接近机翼后掠角的互补角时，RCS最大
    sweep_effect = cos(theta - (pi/2 - wing_sweep))^2;
    
    % 俯仰角效应 (从上方或下方看时RCS较大)
    pitch_effect = sin(phi)^2;
    
    % 基础RCS值
    base_rcs = 2.0;
    
    % 计算机翼RCS
    rcs = base_rcs * (sweep_effect + 0.5 * pitch_effect);
    
    % 从侧面观察时RCS较大
    if abs(theta - pi/2) < 0.3 || abs(theta - 3*pi/2) < 0.3
        rcs = rcs * 3;
    end
end

%% 计算机身RCS的辅助函数
function rcs = calculateBodyRCS(fighter, theta, phi)
    % 计算机身在给定角度的RCS贡献
    
    % 提取参数
    L = fighter.L;
    W = fighter.W;
    H = fighter.H;
    
    % 计算有效面积
    % 从不同角度看飞机时的投影面积
    projected_area = L * H * abs(cos(theta)) + W * H * abs(sin(theta)) + L * W * abs(sin(phi));
    
    % 角度因子 (边缘入射时RCS较小)
    angle_factor = (cos(theta)^2 + sin(theta)^2 * cos(phi)^2);
    
    % 基础RCS值
    base_rcs = 1.0;
    
    % 计算机身RCS
    rcs = base_rcs * projected_area / (L * W) * angle_factor;
    
    % 尾部角度效应
    tail_angle = fighter.params.tail_angle * pi/180;
    if abs(theta - pi) < 0.3  % 从后方观察
        rcs = rcs * (1 + sin(tail_angle));
    end
end

%% 可视化RCS函数
function visualizeRCS(theta, phi, rcs, title_text)
    figure;
    
    % 使用对数尺度显示RCS
    rcs_db = 10 * log10(rcs);
    
    % 创建极坐标网格
    [THETA, PHI] = meshgrid(theta, phi);
    [X, Y, Z] = sph2cart(THETA, PHI, rcs);
    
    % 绘制3D RCS图
    subplot(2, 2, 1);
    surf(X, Y, Z, rcs_db);
    colorbar;
    title('3D RCS分布');
    xlabel('X方向');
    ylabel('Y方向');
    zlabel('Z方向');
    axis equal;
    colormap('jet');
    
    % 绘制水平面RCS极坐标图（俯仰角=0）
    subplot(2, 2, 2);
    polar_idx = floor(length(phi)/2);  % 选择俯仰角接近0的索引
    polarplot(theta, rcs(polar_idx, :));
    title('水平面RCS (俯仰角=0°)');
    
    % 绘制热图
    subplot(2, 2, 3);
    imagesc(theta*180/pi, phi*180/pi, rcs_db);
    colorbar;
    xlabel('方位角 (度)');
    ylabel('俯仰角 (度)');
    title('RCS热图 (dBsm)');
    
    % 绘制俯仰面RCS
    subplot(2, 2, 4);
    front_idx = 1;  % 正面方位角索引
    side_idx = floor(length(theta)/4);  % 侧面方位角索引
    plot(phi*180/pi, rcs_db(:, front_idx), 'b-', 'LineWidth', 2);
    hold on;
    plot(phi*180/pi, rcs_db(:, side_idx), 'r--', 'LineWidth', 2);
    xlabel('俯仰角 (度)');
    ylabel('RCS (dBsm)');
    title('不同方位角的俯仰RCS');
    legend('正面 (0°)', '侧面 (90°)');
    grid on;
    
    % 设置总标题
    sgtitle(title_text);
end

%% 对比优化前后的RCS
function compareRCS(theta1, phi1, rcs1, theta2, phi2, rcs2)
    figure;
    
    % 转换为dB单位
    rcs1_db = 10 * log10(rcs1);
    rcs2_db = 10 * log10(rcs2);
    
    % 计算改进百分比
    improvement = (rcs1 - rcs2) ./ rcs1 * 100;
    avg_improvement = mean(improvement(:));
    
    % 绘制水平面RCS对比（俯仰角=0）
    subplot(2, 2, 1);
    polar_idx = floor(length(phi1)/2);  % 选择俯仰角接近0的索引
    polarplot(theta1, rcs1(polar_idx, :), 'b-', 'LineWidth', 1.5);
    hold on;
    polarplot(theta2, rcs2(polar_idx, :), 'r--', 'LineWidth', 1.5);
    title('水平面RCS对比 (俯仰角=0°)');
    legend('初始设计', '优化设计');
    
    % 绘制改进热图
    subplot(2, 2, 2);
    imagesc(theta1*180/pi, phi1*180/pi, improvement);
    colorbar;
    xlabel('方位角 (度)');
    ylabel('俯仰角 (度)');
    title(sprintf('RCS改进百分比 (平均: %.1f%%)', avg_improvement));
    colormap('jet');
    
    % 绘制正面RCS对比
    subplot(2, 2, 3);
    front_idx = 1;  % 正面方位角索引
    plot(phi1*180/pi, rcs1_db(:, front_idx), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(phi2*180/pi, rcs2_db(:, front_idx), 'r--', 'LineWidth', 1.5);
    xlabel('俯仰角 (度)');
    ylabel('RCS (dBsm)');
    title('正面RCS对比 (方位角=0°)');
    legend('初始设计', '优化设计');
    grid on;
    
    % 绘制侧面RCS对比
    subplot(2, 2, 4);
    side_idx = floor(length(theta1)/4);  % 侧面方位角索引
    plot(phi1*180/pi, rcs1_db(:, side_idx), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(phi2*180/pi, rcs2_db(:, side_idx), 'r--', 'LineWidth', 1.5);
    xlabel('俯仰角 (度)');
    ylabel('RCS (dBsm)');
    title('侧面RCS对比 (方位角=90°)');
    legend('初始设计', '优化设计');
    grid on;
    
    % 设置总标题
    sgtitle('优化前后RCS对比分析');
end

%% 显示优化结果
function displayOptimizationResults(initial_params, optimized_params)
    % 打印优化结果
    param_names = fieldnames(initial_params);
    
    figure;
    
    % 创建参数比较表格
    param_table = zeros(length(param_names), 2);
    for i = 1:length(param_names)
        param_table(i, 1) = initial_params.(param_names{i});
        param_table(i, 2) = optimized_params.(param_names{i});
    end
    
    % 绘制参数对比条形图
    subplot(1, 2, 1);
    bar(param_table);
    set(gca, 'XTickLabel', param_names);
    xtickangle(45);
    ylabel('参数值');
    title('优化前后参数对比');
    legend('初始设计', '优化设计');
    grid on;
    
    % 计算变化百分比
    change_percent = (param_table(:, 2) - param_table(:, 1)) ./ param_table(:, 1) * 100;
    
    % 绘制变化百分比
    subplot(1, 2, 2);
    barh(change_percent);
    set(gca, 'YTickLabel', param_names);
    xlabel('变化百分比 (%)');
    title('参数变化百分比');
    grid on;
    
    % 给条形图添加数值标签
    for i = 1:length(change_percent)
        if change_percent(i) >= 0
            text(change_percent(i) + 2, i, sprintf('+%.1f%%', change_percent(i)));
        else
            text(change_percent(i) - 10, i, sprintf('%.1f%%', change_percent(i)));
        end
    end
    
    % 设置总标题
    sgtitle('设计参数优化结果');
end

%% 遗传算法优化设计
function optimized_params = optimizeDesign(initial_params)
    % 使用遗传算法优化设计参数以减小RCS
    
    % 定义参数范围
    param_ranges = struct(...
        'length', [15, 25],... % 飞机长度(m)
        'width', [10, 20],... % 机翼展开宽度(m)
        'height', [2, 6],... % 飞机高度(m)
        'nose_angle', [20, 60],... % 机头角度(度)
        'wing_sweep', [30, 70],... % 机翼后掠角(度)
        'tail_angle', [20, 50]); % 尾部角度(度)
    
    % 获取参数名
    param_names = fieldnames(initial_params);
    n_params = length(param_names);
    
    % 遗传算法参数
    population_size = 20;
    max_generations = 10;
    elite_count = 2;
    crossover_fraction = 0.8;
    
    % 创建初始种群
    population = zeros(population_size, n_params);
    for i = 1:population_size
        for j = 1:n_params
            name = param_names{j};
            if i == 1 % 第一个个体使用初始参数
                population(i, j) = initial_params.(name);
            else % 其他个体随机生成
                range = param_ranges.(name);
                population(i, j) = range(1) + rand() * (range(2) - range(1));
            end
        end
    end
    
    % 存储最优个体
    best_fitness = Inf;
    best_individual = population(1, :);
    
    % 显示优化进度
    disp('开始遗传算法优化：');
    fprintf('代数\t最优RCS\t平均RCS\n');
    
    % 主遗传算法循环
    for generation = 1:max_generations
        % 计算适应度
        fitness = zeros(population_size, 1);
        for i = 1:population_size
            % 创建参数结构体
            params = struct();
            for j = 1:n_params
                params.(param_names{j}) = population(i, j);
            end
            
            % 计算RCS
            fighter = createFighterModel(params);
            [~, ~, rcs] = calculateRCS(fighter);
            
            % 适应度为平均RCS（较小值更好）
            fitness(i) = mean(rcs(:));
        end
        
        % 更新最优个体
        [min_fitness, min_idx] = min(fitness);
        if min_fitness < best_fitness
            best_fitness = min_fitness;
            best_individual = population(min_idx, :);
        end
        
        % 显示当前代数信息
        fprintf('%d\t%.4f\t%.4f\n', generation, min_fitness, mean(fitness));
        
        % 选择父代
        [~, sorted_idx] = sort(fitness);
        elite_idx = sorted_idx(1:elite_count);
        
        % 保留精英个体
        new_population = population(elite_idx, :);
        
        % 创建其余后代
        while size(new_population, 1) < population_size
            % 选择父母
            parent1_idx = tournamentSelection(fitness);
            parent2_idx = tournamentSelection(fitness);
            
            % 交叉
            if rand() < crossover_fraction
                [child1, child2] = crossover(population(parent1_idx, :), population(parent2_idx, :));
            else
                child1 = population(parent1_idx, :);
                child2 = population(parent2_idx, :);
            end
            
            % 变异
            child1 = mutate(child1, param_ranges, param_names, 0.2);
            child2 = mutate(child2, param_ranges, param_names, 0.2);
            
            % 添加到新种群
            new_population = [new_population; child1; child2];
        end
        
        % 确保种群大小正确
        if size(new_population, 1) > population_size
            new_population = new_population(1:population_size, :);
        end
        
        % 更新种群
        population = new_population;
    end
    
    % 创建最优参数结构体
    optimized_params = struct();
    for j = 1:n_params
        optimized_params.(param_names{j}) = best_individual(j);
    end
    
    % 显示优化结果
    disp('优化完成！');
    disp('最优设计参数：');
    disp(optimized_params);
end

%% 遗传算法辅助函数：锦标赛选择
function selected_idx = tournamentSelection(fitness)
    % 随机选择2个个体进行比较，选择适应度较好的那个
    population_size = length(fitness);
    candidates = randi(population_size, 1, 2);
    [~, winner] = min(fitness(candidates));
    selected_idx = candidates(winner);
end

%% 遗传算法辅助函数：交叉
function [child1, child2] = crossover(parent1, parent2)
    % 单点交叉
    n_params = length(parent1);
    crossover_point = randi(n_params - 1);
    
    child1 = [parent1(1:crossover_point), parent2(crossover_point+1:end)];
    child2 = [parent2(1:crossover_point), parent1(crossover_point+1:end)];
end

%% 遗传算法辅助函数：变异
function child = mutate(parent, param_ranges, param_names, mutation_rate)
    child = parent;
    
    for i = 1:length(parent)
        % 对每个参数以一定概率进行变异
        if rand() < mutation_rate
            name = param_names{i};
            range = param_ranges.(name);
            
            % 生成范围内的新值
            new_value = range(1) + rand() * (range(2) - range(1));
            
            % 更新变异后的值
            child(i) = new_value;
        end
    end
end