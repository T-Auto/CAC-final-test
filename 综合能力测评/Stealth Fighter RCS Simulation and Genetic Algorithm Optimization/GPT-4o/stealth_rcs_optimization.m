clear; clc; close all;

% 参数范围（用于遗传算法）
lb = [2, 1, 0.2]; % 机头长度，机身宽度，倾斜角（弧度）
ub = [6, 3, pi/4];

% 遗传算法优化
options = optimoptions('ga','MaxGenerations',30,'PopulationSize',30,...
    'Display','iter','PlotFcn',{@gaplotbestf});
[x_opt,fval] = ga(@(x) rcs_fitness(x), 3, [], [], [], [], lb, ub, [], options);

% 可视化最终优化模型和RCS
disp('最优参数：'); disp(x_opt);
disp(['最小平均 RCS：', num2str(fval), ' m^2']);

% 绘制最终模型与方向RCS
plot_final_model_and_rcs(x_opt);
