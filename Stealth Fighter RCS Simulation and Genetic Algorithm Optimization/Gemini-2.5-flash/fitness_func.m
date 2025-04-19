% fitness_func.m
% 遗传算法的适应度函数
% 计算模型在指定方向上的平均线性RCS

function avg_rcs_linear = fitness_func(params, frequency, directions)

% 创建模型并获取几何信息
% 检查参数是否可能导致无效模型 (例如，x_mid_frac 导致 x_mid 超出 [0, L])
L = params(1);
x_mid_frac = params(4);
if x_mid_frac < 0 || x_mid_frac > 1
    avg_rcs_linear = 1e6; % 返回一个非常大的值作为惩罚
    return;
end
x_mid = L * x_mid_frac;
if x_mid < 0 || x_mid > L
     avg_rcs_linear = 1e6; % 返回一个非常大的值作为惩罚
     return;
end

% 检查其他尺寸参数是否合理 (例如，宽度/高度不能为负)
if any(params(2:3) < 0) || any(params(5:6) < 0)
     avg_rcs_linear = 1e6; % 返回一个非常大的值作为惩罚
     return;
end

% 检查几何约束，例如中间宽度/高度是否大于尾部 (可选，根据设计需求)
% if params(5) < params(2) || params(6) < params(3)
%      avg_rcs_linear = 1e6; % 返回一个非常大的值作为惩罚
%      return;
% end

% createStealthModel 现在返回 faces_patch_matrix (用于patch) 和 faces_cell (用于RCS)
[vertices, ~, normals, areas, centroids, faces_cell] = createStealthModel(params);

% 检查模型创建是否成功 (例如，没有 NaN 法向量)
if any(isnan(normals(:))) || any(isnan(areas(:))) || any(isnan(centroids(:))) || isempty(faces_cell)
    avg_rcs_linear = 1e6; % 返回一个非常大的值作为惩罚
    return;
end


% 计算指定方向上的RCS
num_directions = size(directions, 1);
rcs_linear_values = zeros(num_directions, 1); % 存储线性RCS值

for i = 1:num_directions
    az = directions(i, 1);
    el = directions(i, 2);

    % calculateRCS_PO 返回 dBsm，需要转换为线性值
    % 注意：这里将 faces_cell 传递给 calculateRCS_PO
    rcs_dBsm = calculateRCS_PO(vertices, faces_cell, normals, areas, centroids, frequency, az, el);

    % 将 dBsm 转换为线性值 (sigma)
    % 避免 log10(-inf) 导致的问题
    if isfinite(rcs_dBsm)
        rcs_linear_values(i) = 10^(rcs_dBsm / 10);
    else
        rcs_linear_values(i) = 1e-10; % 对于非常小的RCS，使用一个接近零的正值
    end
end

% 计算平均线性RCS (遗传算法将最小化这个值)
% 最小化平均线性RCS等同于最小化平均功率
avg_rcs_linear = mean(rcs_linear_values);

% 如果平均RCS非常小 (接近零)，可能意味着模型有问题或计算错误
% 可以设置一个阈值，如果低于阈值则惩罚 (可选)
% if avg_rcs_linear < 1e-9 % 例如 -90 dBsm
%      avg_rcs_linear = 1e-9 + (1e-9 - avg_rcs_linear); % 惩罚
% end


end