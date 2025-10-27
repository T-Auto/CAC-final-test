% calculateRCS_PO.m
% 使用物理光学 (PO) 近似计算多面体目标的RCS (后向散射)

function rcs_dBsm = calculateRCS_PO(vertices, faces, normals, areas, centroids, frequency, incident_az, incident_el)

c = 299792458; % 光速
lambda = c / frequency; % 波长
k = 2 * pi / lambda; % 波数

% 入射方向向量 (从雷达到目标)
% incident_az: 方位角 (0度沿+X轴, 90度沿+Y轴)
% incident_el: 仰角 (0度在XY平面, 90度沿+Z轴)
% 雷达波从这个方向入射到目标
k_inc = -[cosd(incident_el) * cosd(incident_az), ...
          cosd(incident_el) * sind(incident_az), ...
          sind(incident_el)];

% 对于后向散射，散射方向与入射方向相反
k_scat = -k_inc;

% 物理光学积分求和
% E_s_sum 对应于 PO 积分 \int (n x H_inc) exp(j k r' . k_scat) dS
% 对于后向散射，k_scat = -k_inc
% 且对于 PEC，J_s = 2 * n x H_inc on illuminated surface
% 散射场 E_s 远场近似正比于 \int J_s exp(-j k r' . k_inc) dS
% E_s \propto \sum_{facets} (n_i x H_inc) Area_i exp(-j k r'_i . k_inc)
% 对于总 RCS (极化无关的简单近似)，可以简化为与 (n_i . k_inc) 相关
% 更精确的 VV 极化后向散射场 E_s_VV \propto \sum_{illuminated} (n_i . k_inc) Area_i exp(-j 2 k r'_i . k_inc)
% RCS_VV = (4*pi/lambda^2) * |E_s_VV|^2 / |E_inc|^2
% 假设 |E_inc|=1，常数项可以合并或忽略相对计算。
% 我们计算 | \sum (n_i . k_inc) Area_i exp(-j 2 k r'_i . k_inc) |^2
% 然后乘以 (4*pi/lambda^2) 得到 RCS

E_s_sum = 0; % 初始化散射场总和 (复数)

num_faces = length(faces);

for i = 1:num_faces
    n = normals(i, :);
    Area = areas(i);
    r_prime = centroids(i, :);

    % 检查面是否被照射 (法向量与入射方向点积 < 0 表示法向量指向远离雷达的方向，即被照射)
    % 这里的法向量是朝外的
    is_illuminated = dot(n, k_inc) < 0;

    if is_illuminated
        % 计算每个面的贡献
        % contribution = dot(n, k_inc) * Area * exp(-1j * 2 * k * dot(k_inc, r_prime));
        % 上述是基于 VV 极化的简化。对于总 RCS，更接近于 |n x H_inc|
        % 假设 H_inc 垂直于 k_inc 且幅度为 1。|n x H_inc| = |n| |H_inc| sin(angle(n, H_inc))
        % H_inc 方向取决于极化。为了简单，我们使用与 (n . k_inc) 相关的形式，它捕捉了镜面反射的主瓣。
        % 当 n 与 -k_inc 平行时 (镜面反射)，dot(n, k_inc) 达到最小值 -1，贡献最大。
        % 使用 dot(n, -k_inc) = -dot(n, k_inc) 作为幅度因子，使其在镜面方向为正最大。
        % 或者直接使用 dot(n, k_scat)
        contribution = dot(n, k_scat) * Area * exp(1j * k * dot(k_scat - k_inc, r_prime)); % 通用 PO 积分形式
        % 对于后向散射 k_scat = -k_inc, k_scat - k_inc = -2*k_inc
        contribution = dot(n, -k_inc) * Area * exp(-1j * 2 * k * dot(k_inc, r_prime));

        E_s_sum = E_s_sum + contribution;
    end
end

% 计算 RCS (线性值)
% sigma = (4 * pi / lambda^2) * abs(E_s_sum)^2; % 包含常数项
% 简化形式，用于相对比较和优化
sigma = abs(E_s_sum)^2; % 相对 RCS

% 转换为 dBsm
if sigma > 0
    rcs_dBsm = 10 * log10(sigma);
else
    rcs_dBsm = -inf; % 或者一个非常小的数，如 -1000
end

end