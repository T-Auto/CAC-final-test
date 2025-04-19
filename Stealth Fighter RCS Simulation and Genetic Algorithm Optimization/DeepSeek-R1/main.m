% 主程序：隐身战斗机RCS优化
clc; clear; close all;

% 参数设置
lambda = 0.03; % 雷达波长（米）
freq = 10e9; % 雷达频率（Hz）
c = 3e8;
lambda = c / freq; % 重新计算波长

% 遗传算法参数设置
nvars = 2; % 设计变量：机翼倾斜角、尾翼倾斜角
lb = [0, 0]; % 下限（度）
ub = [90, 90]; % 上限（度）
options = optimoptions('ga', 'PopulationSize', 30, 'MaxGenerations', 50, 'Display', 'iter');

% 运行遗传算法优化
[x_opt, fval] = ga(@(x)rcs_objective(x, lambda), nvars, [], [], [], [], lb, ub, [], options);

% 输出优化结果
fprintf('优化结果：机翼倾斜角=%.2f°，尾翼倾斜角=%.2f°，平均RCS=%.2f dBsm\n', x_opt(1), x_opt(2), fval);

% 可视化优化前后的模型和RCS
plot_optimization_results(x_opt, lambda);

% 适应度函数：计算平均RCS
function f = rcs_objective(x, lambda)
    theta_wing = x(1);
    theta_tail = x(2);
    
    % 各部件参数
    A_wing = 10; % 机翼面积
    A_tail = 2;  % 尾翼面积
    A_body = 5;  % 机身面积
    
    % 法线向量计算
    n_wing = [0, sind(theta_wing), cosd(theta_wing)];
    n_tail = [sind(theta_tail), 0, cosd(theta_tail)];
    n_body = [0, 0, 1];
    
    % 方位角扫描
    phi = 0:5:360;
    total_rcs = 0;
    
    for i = 1:length(phi)
        v = [cosd(phi(i)), sind(phi(i)), 0]; % 入射方向
        
        % 计算各部件RCS
        theta_wing_incident = acosd(dot(n_wing, v));
        sigma_wing = (4*pi*A_wing^2/lambda^2) * (cosd(theta_wing_incident))^4;
        
        theta_tail_incident = acosd(dot(n_tail, v));
        sigma_tail = (4*pi*A_tail^2/lambda^2) * (cosd(theta_tail_incident))^4;
        
        theta_body_incident = acosd(dot(n_body, v));
        sigma_body = (4*pi*A_body^2/lambda^2) * (cosd(theta_body_incident))^4;
        
        total_rcs = total_rcs + sigma_wing + sigma_tail + sigma_body;
    end
    
    f = total_rcs / length(phi); % 平均RCS
end

% 可视化优化结果
function plot_optimization_results(x_opt, lambda)
    % 初始设计（角度为0）
    theta_wing_initial = 0;
    theta_tail_initial = 0;
    
    % 绘制三维模型对比
    figure('Position', [100, 100, 1200, 500]);
    subplot(1,2,1);
    plot_aircraft(theta_wing_initial, theta_tail_initial);
    title('初始设计');
    
    subplot(1,2,2);
    plot_aircraft(x_opt(1), x_opt(2));
    title('优化设计');
    
    % 计算并绘制RCS方向图
    [phi, rcs_initial, rcs_opt] = calculate_rcs_comparison(theta_wing_initial, theta_tail_initial, x_opt(1), x_opt(2), lambda);
    
    figure;
    polarplot(deg2rad(phi), 10*log10(rcs_initial), 'r', 'LineWidth', 2);
    hold on;
    polarplot(deg2rad(phi), 10*log10(rcs_opt), 'b--', 'LineWidth', 2);
    title('RCS方向图对比 (dBsm)');
    legend('初始设计', '优化设计', 'Location', 'southoutside');
    rlim([0 50]); % 调整径向范围
end

% 绘制三维飞机模型
function plot_aircraft(theta_wing, theta_tail)
    % 机翼参数
    W_wing = 10; L_wing = 5;
    wing_x = [-W_wing/2, W_wing/2, W_wing/2, -W_wing/2];
    wing_y = [-L_wing/2, -L_wing/2, L_wing/2, L_wing/2];
    wing_z = zeros(1,4);
    
    % 机翼旋转（绕X轴）
    R_x = [1 0 0; 0 cosd(theta_wing) -sind(theta_wing); 0 sind(theta_wing) cosd(theta_wing)];
    for i = 1:4
        pt = R_x * [wing_x(i); wing_y(i); wing_z(i)];
        wing_x_rot(i) = pt(1); wing_y_rot(i) = pt(2); wing_z_rot(i) = pt(3);
    end
    
    % 尾翼参数
    W_tail = 2; L_tail = 4;
    tail_x = [-W_tail/2, W_tail/2, W_tail/2, -W_tail/2];
    tail_z = [-L_tail/2, -L_tail/2, L_tail/2, L_tail/2];
    tail_y = zeros(1,4);
    
    % 尾翼旋转（绕Y轴）
    R_y = [cosd(theta_tail) 0 sind(theta_tail); 0 1 0; -sind(theta_tail) 0 cosd(theta_tail)];
    for i = 1:4
        pt = R_y * [tail_x(i); tail_y(i); tail_z(i)];
        tail_x_rot(i) = pt(1); tail_y_rot(i) = pt(2); tail_z_rot(i) = pt(3);
    end
    
    % 机身参数
    W_body = 3; L_body = 15;
    body_x = [-W_body/2, W_body/2, W_body/2, -W_body/2];
    body_y = [-L_body/2, -L_body/2, L_body/2, L_body/2];
    body_z = zeros(1,4);
    
    % 绘制
    patch(wing_x_rot, wing_y_rot, wing_z_rot, 'b', 'FaceAlpha', 0.5);
    hold on;
    patch(tail_x_rot, tail_y_rot, tail_z_rot, 'r', 'FaceAlpha', 0.5);
    patch(body_x, body_y, body_z, 'g', 'FaceAlpha', 0.5);
    
    xlabel('X'); ylabel('Y'); zlabel('Z');
    axis equal; grid on; view(45, 30);
end

% 计算RCS对比
function [phi, rcs_initial, rcs_opt] = calculate_rcs_comparison(theta_wing_initial, theta_tail_initial, theta_wing_opt, theta_tail_opt, lambda)
    phi = 0:5:360;
    rcs_initial = zeros(size(phi));
    rcs_opt = zeros(size(phi));
    
    A_wing = 10; A_tail = 2; A_body = 5;
    
    for i = 1:length(phi)
        v = [cosd(phi(i)), sind(phi(i)), 0];
        
        % 初始设计RCS
        n_wing_initial = [0, sind(theta_wing_initial), cosd(theta_wing_initial)];
        n_tail_initial = [sind(theta_tail_initial), 0, cosd(theta_tail_initial)];
        n_body_initial = [0, 0, 1];
        
        theta_wing_initial_incident = acosd(dot(n_wing_initial, v));
        theta_tail_initial_incident = acosd(dot(n_tail_initial, v));
        theta_body_initial_incident = acosd(dot(n_body_initial, v));
        
        sigma_initial = (4*pi*A_wing^2/lambda^2)*(cosd(theta_wing_initial_incident))^4 + ...
                       (4*pi*A_tail^2/lambda^2)*(cosd(theta_tail_initial_incident))^4 + ...
                       (4*pi*A_body^2/lambda^2)*(cosd(theta_body_initial_incident))^4;
        rcs_initial(i) = sigma_initial;
        
        % 优化设计RCS
        n_wing_opt = [0, sind(theta_wing_opt), cosd(theta_wing_opt)];
        n_tail_opt = [sind(theta_tail_opt), 0, cosd(theta_tail_opt)];
        
        theta_wing_opt_incident = acosd(dot(n_wing_opt, v));
        theta_tail_opt_incident = acosd(dot(n_tail_opt, v));
        theta_body_opt_incident = acosd(dot(n_body_initial, v));
        
        sigma_opt = (4*pi*A_wing^2/lambda^2)*(cosd(theta_wing_opt_incident))^4 + ...
                   (4*pi*A_tail^2/lambda^2)*(cosd(theta_tail_opt_incident))^4 + ...
                   (4*pi*A_body^2/lambda^2)*(cosd(theta_body_opt_incident))^4;
        rcs_opt(i) = sigma_opt;
    end
end