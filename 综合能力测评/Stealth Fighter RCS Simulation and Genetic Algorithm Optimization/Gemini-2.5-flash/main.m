%% MATLAB程序：隐身战斗机简化建模、RCS计算与遗传算法优化

% 要求1：一次性完成完整的，可运行的程序
% 要求2：使用三维建模查看隐身战斗机以及各方向的雷达反射截面
% 要求3：把最终的结论可视化作图

clear; clc; close all;
rng('default'); % 设置随机种子，以便结果可复现

%% 1. 参数定义与初始模型创建

% 定义基础尺寸（单位可认为是米），优化时这些尺寸按比例变化或角度变化
base_length = 10;
base_width = 6;
base_height = 2;
base_wing_span = 8;
base_wing_chord_root = 4;
base_wing_chord_tip = 1.5; % 初始锥度比 base_wing_chord_tip / base_wing_chord_root = 0.375

% 定义初始设计参数（用于遗传算法优化）
% 这些参数会影响模型的几何形状，如体型比例、斜面角度、机翼参数等
% 参数1: Body taper front ratio (0-1) - 前部锥度比，越小越尖 (0.1-0.5)
% 参数2: Body taper back ratio (0-1) - 后部锥度比，越小越尖 (0.5-1.0)
% 参数3: Body top angle (deg) - 顶部斜面角度 (0-45度) - 相对于水平面
% 参数4: Body bottom angle (deg) - 底部斜面角度 (0-45度) - 相对于水平面
% 参数5: Wing sweep angle (deg) - 机翼后掠角 (10-60度) - 相对于横向(Y)轴
% 参数6: Wing taper ratio (chord_tip/chord_root) - 机翼锥度比 (0.2-1)
% 参数7: Wing span ratio (span/base_width) - 机翼展长与体宽比 (0.8-1.5)
initial_params = [0.3, 0.8, 15, 10, 40, 0.5, 1.2]; % 一个示例的初始设计

% 参数的上下界（用于遗传算法）
lb = [0.1, 0.5, 0, 0, 10, 0.2, 0.8];
ub = [0.5, 1.0, 45, 45, 60, 1.0, 1.5];

num_params = length(initial_params);

% 雷达波长 (单位与尺寸一致)
% 注意：本简化的RCS计算方法主要依赖于面的法向和面积，波长的影响在此模型中被高度简化或忽略。
% 在更精确的物理光学或全波计算中，波长是关键参数。
lambda = 0.1; % 例如，X波段雷达 (~3 GHz)，波长约 0.1 米

% 定义用于RCS计算的雷达角度（仅考虑水平面方位角，0度迎头）
% 方位角 (Azimuth): 0度为机头方向 (正X轴)，逆时针旋转为正。这里考虑 0 到 180 度。
% 俯仰角 (Elevation): 0度为水平面。这里固定为 0 度。
rcs_azimuth_angles_deg = 0:5:180; % 0度到180度，间隔5度
rcs_elevation_angle_deg = 0; % 假设雷达在同一水平面

%% 2. 几何模型创建函数
% 根据参数生成隐身战斗机的简化三维模型（顶点和面）
% 所有面都定义为三角形
function [vertices, faces] = createFighterModel(params, base_dims)
    % params: 遗传算法传递的设计参数
    % base_dims: 基础尺寸 [length, width, height, wing_span, chord_root, chord_tip]

    p_taper_front = params(1);
    p_taper_back = params(2);
    p_angle_top = deg2rad(params(3)); % 转换为弧度
    p_angle_bottom = deg2rad(params(4));
    p_wing_sweep = deg2rad(params(5));
    p_wing_taper_ratio = params(6);
    p_wing_span_ratio = params(7);

    body_length = base_dims(1);
    body_width = base_dims(2);
    body_height = base_dims(3);
    % 根据比例参数调整翼展和翼尖弦长
    actual_wing_span = base_dims(4) * p_wing_span_ratio;
    actual_wing_chord_root = base_dims(5); % 根弦长通常不变，翼尖弦长变化
    actual_wing_chord_tip = actual_wing_chord_root * p_wing_taper_ratio;

    % --- 定义机身顶点 ---
    % 机身简化为一个带有斜面和锥度的多边形体
    % 假设机身中点在原点 (0,0,0)
    % 顶点顺序：前尖，前基面，中段，后基面，后尖
    % X轴沿机身方向 (前+)，Y轴横向 (左+)，Z轴垂直 (上+)

    x_front_tip = body_length / 2;
    x_front_base = body_length / 2 * (1 - p_taper_front); % 前基面位置 (X)
    x_middle = 0; % 机身最宽/高处 (简化为中点)
    x_back_base = -body_length / 2 * (1 - p_taper_back); % 后基面位置 (X)
    x_back_tip = -body_length / 2;

    y_middle_half_width = body_width / 2;
    z_middle_top_half = body_height / 2;
    z_middle_bottom_half = -body_height / 2;

    % Mid body vertices (defining the central cross-section rectangle)
    % 这是机身最宽/高处，简化为一个矩形截面
    v_mid = [
        x_middle,  y_middle_half_width,  z_middle_top_half;    % 1: Mid Top Right (+Y, +Z)
        x_middle, -y_middle_half_width,  z_middle_top_half;    % 2: Mid Top Left (-Y, +Z)
        x_middle, -y_middle_half_width,  z_middle_bottom_half; % 3: Mid Bottom Left (-Y, -Z)
        x_middle,  y_middle_half_width,  z_middle_bottom_half; % 4: Mid Bottom Right (+Y, -Z)
    ];

    % Front base vertices (derived from mid section and taper ratio, with angles)
    % 前基面位置，比中段窄/低，并考虑顶/底斜面
    x_fb = x_front_base;
    y_fb_half_width = y_middle_half_width * (1 - p_taper_front); % Y向收缩
    % 根据顶部斜面角度计算前基面顶部 Z 坐标
    % 从中段顶部 (x_middle, z_middle_top_half) 向前走到 x_fb
    % 垂直高度变化量 = (x_front_tip - x_fb) * tan(p_angle_top) -- 注意这里的X方向
    % 简化处理：假设斜面从前尖开始应用，斜面底部起点是前基面。
    % 或者假设斜面从机身中段向前后延伸。这里采用斜面从前尖向后延伸到前基面，再到中段的简化模型。
    % 更合理的模型是斜面从机身最厚处向前后延伸。我们用后者。
    % 从中段顶部 (x_middle, z_middle_top_half) 向前到 x_fb 的高度变化： (x_fb - x_middle) * tan(p_angle_top)
    % 因为 x_fb > x_middle，且斜面向上收，所以顶部 Z 坐标应该是 z_middle_top_half 减去高度变化
    z_fb_top = z_middle_top_half - (x_fb - x_middle) * tan(p_angle_top);
     % 从中段底部 (x_middle, z_middle_bottom_half) 向前到 x_fb 的高度变化： (x_fb - x_middle) * tan(p_angle_bottom)
     % 因为 x_fb > x_middle，且斜面向下收，所以底部 Z 坐标应该是 z_middle_bottom_half 加上高度变化
    z_fb_bottom = z_middle_bottom_half + (x_fb - x_middle) * tan(p_angle_bottom);

    % 确保前基面 Z 坐标不会超出中段高度范围（虽然角度计算一般不会）
    z_fb_top = min(z_fb_top, z_middle_top_half);
    z_fb_bottom = max(z_fb_bottom, z_middle_bottom_half);


     v_front_base = [
        x_fb,  y_fb_half_width,  z_fb_top;    % 5: Front Base Top Right
        x_fb, -y_fb_half_width,  z_fb_top;    % 6: Front Base Top Left
        x_fb, -y_fb_half_width,  z_fb_bottom; % 7: Front Base Bottom Left
        x_fb,  y_fb_half_width,  z_fb_bottom; % 8: Front Base Bottom Right
    ];


    % Back base vertices (derived from mid section and taper ratio, with angles)
    % 后基面位置，比中段窄/低，并考虑顶/底斜面
    x_bb = x_back_base;
    y_bb_half_width = y_middle_half_width * (1 - p_taper_back); % Y向收缩
     % 从中段顶部 (x_middle, z_middle_top_half) 向后到 x_bb 的高度变化： (x_middle - x_bb) * tan(p_angle_top)
     % 因为 x_middle > x_bb，且斜面向上收，所以顶部 Z 坐标应该是 z_middle_top_half 减去高度变化
    z_bb_top = z_middle_top_half - (x_middle - x_bb) * tan(p_angle_top);
     % 从中段底部 (x_middle, z_middle_bottom_half) 向后到 x_bb 的高度变化： (x_middle - x_bb) * tan(p_angle_bottom)
     % 因为 x_middle > x_bb，且斜面向下收，所以底部 Z 坐标应该是 z_middle_bottom_half 加上高度变化
    z_bb_bottom = z_middle_bottom_half + (x_middle - x_bb) * tan(p_angle_bottom);

    % 确保后基面 Z 坐标不会超出中段高度范围
    z_bb_top = min(z_bb_top, z_middle_top_half);
    z_bb_bottom = max(z_bb_bottom, z_middle_bottom_half);

    v_back_base = [
        x_bb,  y_bb_half_width,  z_bb_top;    % 9: Back Base Top Right
        x_bb, -y_bb_half_width,  z_bb_top;    % 10: Back Base Top Left
        x_bb, -y_bb_half_width,  z_bb_bottom; % 11: Back Base Bottom Left
        x_bb,  y_bb_half_width,  z_bb_bottom; % 12: Back Base Bottom Right
    ];


    % Front tip vertex (简化：在前尖 X 位置，Y=0，Z取前基面中心高度)
    v_front_tip = [x_front_tip, 0, (z_fb_top + z_fb_bottom)/2]; % 13: Front Tip

    % Back tip vertex (简化：在后尖 X 位置，Y=0，Z取后基面中心高度)
    v_back_tip = [x_back_tip, 0, (z_bb_top + z_bb_bottom)/2]; % 14: Back Tip


    % Combine body vertices
    body_vertices = [
        v_mid;           % 1-4: Mid (TR,TL,BL,BR)
        v_front_base;    % 5-8: Front Base (TR,TL,BL,BR)
        v_back_base;     % 9-12: Back Base (TR,TL,BL,BR)
        v_front_tip;     % 13: Front Tip
        v_back_tip;      % 14: Back Tip
    ];

    % Define body faces (simplified facets), all as TRIANGLES
    % 连接各个截面点和尖点形成三角面

    % 前锥体 (前尖 13 -> 前基面四边形 5,6,7,8)
    body_faces = [
        13, 5, 6; % Top Front (Triangle connecting tip to top edge of front base)
        13, 6, 7; % Left Front (Triangle connecting tip to left edge of front base)
        13, 7, 8; % Bottom Front (Triangle connecting tip to bottom edge of front base)
        13, 8, 5; % Right Front (Triangle connecting tip to right edge of front base)
    ];

    % 前机身段 (前基面四边形 5,6,7,8 -> 中段四边形 1,2,3,4) - 斜面连接
    % 顶面 (近似四边形 5,1,2,6 分割为 2 个三角形)
    body_faces = [body_faces;
        5, 1, 2;
        5, 2, 6;
    ];
    % 底面 (近似四边形 8,4,3,7 分割为 2 个三角形)
     body_faces = [body_faces;
        8, 4, 3;
        8, 3, 7;
    ];
    % 右侧面 (+Y) (近似四边形 5,8,4,1 分割为 2 个三角形)
    body_faces = [body_faces;
        5, 8, 4;
        5, 4, 1;
    ];
    % 左侧面 (-Y) (近似四边形 6,7,3,2 分割为 2 个三角形)
    body_faces = [body_faces;
        6, 7, 3;
        6, 3, 2;
    ];

    % 后机身段 (中段四边形 1,2,3,4 -> 后基面四边形 9,10,11,12) - 斜面连接
    % 顶面 (近似四边形 1,9,10,2 分割为 2 个三角形)
    body_faces = [body_faces;
        1, 9, 10;
        1, 10, 2;
    ];
    % 底面 (近似四边形 4,12,11,3 分割为 2 个三角形)
    body_faces = [body_faces;
        4, 12, 11;
        4, 11, 3;
    ];
    % 右侧面 (+Y) (近似四边形 1,4,12,9 分割为 2 个三角形)
    body_faces = [body_faces;
        1, 4, 12;
        1, 12, 9;
    ];
    % 左侧面 (-Y) (近似四边形 2,3,11,10 分割为 2 个三角形)
    body_faces = [body_faces;
        2, 3, 11;
        2, 11, 10;
    ];

    % 后锥体 (后基面四边形 9,10,11,12 -> 后尖 14)
    body_faces = [body_faces;
        14, 10, 9;  % Top Back
        14, 11, 10; % Left Back
        14, 12, 11; % Bottom Back
        14, 9, 12;  % Right Back
    ];


    % --- 定义机翼顶点和面 ---
    % 简化为两个平面机翼，梯形形状
    % 假设机翼附着在机身中段附近，略低于机身最宽处
    wing_attach_x_ref = x_middle - body_length * 0.1; % 翼根前缘大致位置 (稍微靠后一点)
    wing_attach_y = y_middle_half_width; % 翼根Y坐标 (连接机身最宽处)
    wing_attach_z = z_middle_bottom_half + body_height * 0.1; % 机翼附着点的Z坐标 (略高于底部)

    % Right Wing (vertices defined relative to attachment line, then shifted)
    % 翼根前缘点: (wing_attach_x_ref, wing_attach_y, wing_attach_z)
    % 翼根后缘点: (wing_attach_x_ref - actual_wing_chord_root, wing_attach_y, wing_attach_z)
    % 翼尖 Y 坐标: wing_attach_y + actual_wing_span / 2
    y_root_attach = wing_attach_y;
    y_tip = wing_attach_y + actual_wing_span / 2;
    delta_y_wing = y_tip - y_root_attach;

    % 计算机翼后掠导致的 X 坐标偏移
    % 如果 p_wing_sweep 是从 Y 轴测量的后掠角，则 X 方向的偏移量 = delta_y * tan(p_wing_sweep)
    % 正的后掠角意味着翼尖比翼根更靠后 (X 值更小)
    delta_x_sweep = delta_y_wing * tan(p_wing_sweep);

    % 翼根前缘 X 坐标
    x_root_leading = wing_attach_x_ref;
    % 翼根后缘 X 坐标
    x_root_trailing = x_root_leading - actual_wing_chord_root;

    % 翼尖前缘 X 坐标 (翼根前缘 X - 后掠偏移)
    x_tip_leading = x_root_leading - delta_x_sweep;
    % 翼尖后缘 X 坐标 (翼尖前缘 X - 翼尖弦长)
    x_tip_trailing = x_tip_leading - actual_wing_chord_tip;

    z_wing = wing_attach_z; % 简化: 机翼是平的，Z坐标恒定

    right_wing_vertices = [
        x_root_trailing, y_root_attach, z_wing; % 1: Root Trailing
        x_tip_trailing,  y_tip,         z_wing; % 2: Tip Trailing
        x_tip_leading,   y_tip,         z_wing; % 3: Tip Leading
        x_root_leading,  y_root_attach, z_wing; % 4: Root Leading
    ];

    % Left Wing (mirror of right wing across Y=0 plane)
    left_wing_vertices = right_wing_vertices;
    left_wing_vertices(:, 2) = -left_wing_vertices(:, 2); % Y坐标取反

    % Combine all vertices
    num_body_verts = size(body_vertices, 1);
    vertices = [body_vertices; right_wing_vertices; left_wing_vertices];

    % Define wing faces (single quad for each wing, split into 2 triangles)
    % 顶点索引相对于整个顶点列表
    rw_start_idx = num_body_verts; % 右翼顶点从 body_vertices 结束处开始计数
    lw_start_idx = rw_start_idx + size(right_wing_vertices, 1); % 左翼顶点从右翼顶点结束处开始计数

    % Right Wing faces (使用右翼的四个顶点索引：1,2,3,4 对应整体顶点列表中的 rw_start_idx+1, ..., rw_start_idx+4)
    % 四边形 (RW_Vtx_1, RW_Vtx_2, RW_Vtx_3, RW_Vtx_4) -> 三角形 (RW_Vtx_1, RW_Vtx_2, RW_Vtx_3) 和 (RW_Vtx_1, RW_Vtx_3, RW_Vtx_4)
    right_wing_faces = rw_start_idx + [
        1, 2, 3; % Triangle 1 (Root TE -> Tip TE -> Tip LE)
        1, 3, 4  % Triangle 2 (Root TE -> Tip LE -> Root LE)
    ];

    % Left Wing faces (使用左翼的四个顶点索引：1,2,3,4 对应整体顶点列表中的 lw_start_idx+1, ..., lw_start_idx+4)
    left_wing_faces = lw_start_idx + [
        1, 2, 3; % Triangle 1
        1, 3, 4  % Triangle 2
    ];

    % Combine all faces
    faces = [body_faces; right_wing_faces; left_wing_faces];

    % 注意：这个简化的模型没有考虑机翼和机身的连接融合部分，也没有厚度。

end

%% 3. 简化RCS计算函数
% 使用简化的物理光学方法估算RCS
% assumes all faces are triangles
function rcs_value = calculateRCS(vertices, faces, radarDirection, lambda)
    % vertices: 模型顶点
    % faces: 模型面 (expected to be triangles)
    % radarDirection: 雷达入射方向的单位向量 [kx, ky, kz] (指向目标)
    % lambda: 雷达波长 (在本简化模型中可能未充分利用)

    % 注意：这是一个非常简化的物理光学 (PO) 近似。
    % 它只考虑了每个三角面的法向对雷达方向的贡献，并简单地对这些贡献进行求和 (非相干叠加)。
    % 没有考虑边的绕射、行波等效应，也没有精确计算面的电流分布和辐射场。
    % 结果是一个表示“有效散射面积”的线性值，并非标准的 dBsm 单位。
    % 主要用于比较不同几何形状的相对隐身性能。

    num_faces = size(faces, 1);
    face_rcs_contributions_linear = zeros(num_faces, 1);

    % 定义一个参数控制镜面反射瓣的锐度。值越高，反射越集中在镜面方向。
    % 这个参数 P 类似于 Area * max(0, dot(normal, -incident))^P
    specular_exponent = 30; % 调整此值可以改变RCS瓣的宽度

    incident_direction = radarDirection(:)'; % 确保是行向量
    negative_incident = -incident_direction; % 理想镜面反射方向 (与入射方向相反)

    % PO RCS 基本公式对于平面反射体 A 是 sigma = 4*pi*A^2*|dot(normal, incident)|^2 / lambda^2
    % 这里的简化计算：我们不计算 dBsm，而是计算一个与面面积和方向相关的“有效散射面积”。
    % sum(|dot(normal, -incident)|^P * Area) 是一个简单的代理，用于衡量总体的镜面反射强度。

    for i = 1:num_faces
        face_verts_idx = faces(i, :);

        % 检查面是否有效（包含3个顶点）
        if length(face_verts_idx) ~= 3
             % warning('Skipping non-triangle face.'); % 如果确保了生成的是三角形，可以注释掉
             continue;
        end

        % 检查顶点索引是否在有效范围内
         if any(face_verts_idx < 1) || any(face_verts_idx > size(vertices, 1))
             warning('Skipping face with invalid vertex indices.');
             continue;
         end


        v1 = vertices(face_verts_idx(1), :);
        v2 = vertices(face_verts_idx(2), :);
        v3 = vertices(face_verts_idx(3), :);

        % 向量表示面的两条边
        vec1 = v2 - v1;
        vec2 = v3 - v1;

        % 计算面的法向量 (未归一化)
        face_normal_unnormalized = cross(vec1, vec2);

        % 检查是否存在退化三角形（面积为零或非常小）
        norm_face_normal = norm(face_normal_unnormalized);
        % 使用一个容差来判断是否退化
        if norm_face_normal < 1e-9 % 可以根据模型尺寸调整此容差
            continue; % 跳过退化面 (面积为零)
        end

        % 归一化法向量
        face_normal = face_normal_unnormalized / norm_face_normal;

        % 计算面面积 (三角形面积)
        face_area = 0.5 * norm_face_normal;

        % 计算法向量与理想镜面反射方向（-incident）的夹角余弦
        % cos_theta = dot(face_normal, negative_incident)
        % 如果法向量与 -incident 方向夹角接近 0，说明面正对雷达，反射最强。
        cos_theta = dot(face_normal, negative_incident);

        % 只有当 cos_theta > 0 时，面才“朝向”雷达，产生镜面反射贡献。
        % 使用 max(0, cos_theta) 来忽略背面散射。
        % 使用幂次方 specular_exponent 来模拟镜面反射的集中性。
        contribution = face_area * max(0, cos_theta)^specular_exponent;

        % 将贡献值存储起来
        face_rcs_contributions_linear(i) = contribution;
    end

    % 将所有面的贡献非相干叠加（简单的求和）
    total_rcs_linear = sum(face_rcs_contributions_linear);

    % 返回求和结果作为简化的RCS值（线性，非dBsm）
    rcs_value = total_rcs_linear;

    % 额外的 NaN/Inf 检查
    if ~isfinite(rcs_value)
        rcs_value = 1e9; % 返回一个很大的值作为惩罚
    end

end

%% 4. 遗传算法适应度函数
% 计算给定设计参数下的平均RCS
function fitness = fitnessFunction(params, base_dims, rcs_azimuth_angles_deg, rcs_elevation_angle_deg, lambda)

    % 创建模型
    [vertices, faces] = createFighterModel(params, base_dims);

    % 如果模型创建失败（例如，参数导致几何退化），返回一个很大的健身值作为惩罚
    if isempty(vertices) || isempty(faces) || any(isnan(vertices(:))) || any(isinf(vertices(:)))
        fitness = 1e9; % Penalty for invalid geometry
        return;
    end

    num_angles = length(rcs_azimuth_angles_deg);
    rcs_values_linear = zeros(1, num_angles);

    % 计算每个角度的雷达方向向量并计算RCS
    elevation_rad = deg2rad(rcs_elevation_angle_deg);
    for i = 1:num_angles
        azimuth_rad = deg2rad(rcs_azimuth_angles_deg(i));

        % 雷达方向是从雷达到目标，指向原点 [0,0,0]
        % 方向向量 [kx, ky, kz] = -[cos(el)*cos(az), cos(el)*sin(az), sin(el)]
        radar_direction = -[cos(elevation_rad) * cos(azimuth_rad), ...
                           cos(elevation_rad) * sin(azimuth_rad), ...
                           sin(elevation_rad)];

        % 计算RCS (返回的是线性值)
        rcs_values_linear(i) = calculateRCS(vertices, faces, radar_direction, lambda);

        % 如果RCS计算返回NaN or Inf，说明有问题，赋予大惩罚值并提前退出
        if ~isfinite(rcs_values_linear(i))
             fitness = 1e9;
             return; % Exit early if any angle fails
        end
    end

    % 适应度函数：最小化平均RCS (线性值)
    % 也可以考虑最小化最大RCS (min(max(rcs_values_linear))) 或加权平均，
    % 但最小化平均通常是一个好的起点。
    fitness = mean(rcs_values_linear);

end

%% 5. 可视化函数

% 绘制三维模型
function visualizeModel(vertices, faces, title_str)
    figure('Name', title_str);
    % 使用 patch 函数绘制由顶点和面组成的三维模型
    patch('Vertices', vertices, 'Faces', faces, ...
          'FaceColor', [0.5 0.7 0.9], ... % 面颜色 (淡蓝色)
          'EdgeColor', [0.3 0.3 0.3], ... % 边颜色 (深灰色)
          'FaceLighting','gouraud',...    % 使用 Gouraud 着色
          'AmbientStrength',0.3,...       % 环境光强度
          'DiffuseStrength',0.8,...       % 漫反射强度
          'SpecularStrength',0.9);        % 镜面反射强度
    title(title_str);
    xlabel('X (Forward)'); % X轴：机头方向
    ylabel('Y (Left)');    % Y轴：左侧机翼方向
    zlabel('Z (Up)');      % Z轴：上方
    axis equal; % 保持轴比例一致，避免模型变形
    view(3); % 设置为标准三维视角
    camlight; % 添加光源，使模型看起来更真实
    grid on;
    % 可选：设置相机位置以获得更好的视角
    % campos([50 -50 30]); % Example camera position
    % camzoom(1.2); % Example zoom level
end

% 绘制RCS极坐标图 (2D azimuth)
function visualizeRCS(azimuth_angles_deg, rcs_values_linear, lambda, title_str)
    figure('Name', title_str);

    % 将线性RCS值转换为相对dB值进行绘制。
    % (注：本简化模型计算的不是绝对 dBsm 值)
    % 计算相对 dB 值时，以最大线性 RCS 值为参考 (0 dB)。
    max_rcs_linear = max(rcs_values_linear);

    % 避免对零或负数取对数，并处理 max_rcs_linear 为零的情况
    if max_rcs_linear < eps % eps 是一个很小的数
        % 如果最大RCS接近零，表示散射极弱，相对dB设为一个较大的负值
        rcs_values_dB_rel = -100 * ones(size(rcs_values_linear)); % 例如 -100 dB
         warning('Max linear RCS is near zero. Plotting relative RCS with -100dB floor.');
    else
        % 计算相对 dB 值： 10 * log10(值 / 参考值)
        % 加上 eps 是为了防止 log10(0) 产生 -Inf
        rcs_values_dB_rel = 10 * log10(rcs_values_linear / max_rcs_linear + eps);
    end

    azimuth_rad = deg2rad(azimuth_angles_deg);

    % 确保用于绘图的数据是有限的（非 NaN, Inf）
    finite_indices = isfinite(azimuth_rad) & isfinite(rcs_values_dB_rel);

    % 使用 polarplot 绘制极坐标图
    polarplot(azimuth_rad(finite_indices), rcs_values_dB_rel(finite_indices), 'LineWidth', 1.5);

    title(title_str);
    % 设置极坐标轴方向和零度位置
    set(gca, 'ThetaDir', 'clockwise', ... % 角度顺时针增加
             'ThetaZeroLocation', 'right'); % 0度在右侧 (对应机头方向 +X)
    thetaticks(0:45:180); % 设置角度刻度
    thetalim([0 180]); % 只显示 0 到 180 度范围 (假设模型左右对称)

    % 设置径向轴（R轴）的限制
    rlim auto; % 先让 MATLAB 自动调整一次范围
    % 手动设置一个合理的下限，以更好地显示变化范围，上限通常是 0 dB 相对值
    current_r_limits = rlim;
    % 设置 R轴的下限为当前自动计算的下限或 -60 dB 相对值，取两者中较大的，避免 R轴范围过小或过大。
    % 实际设置时，一般希望下限比所有数据点都小，以便数据显示完整。
    % 这里的 -60 是一个经验值，可以根据实际结果调整。
    r_min_floor = -60; % 设置一个 dB 下限，例如 -60 dB 相对值
    r_max_floor = 0; % 设置一个 dB 上限，相对值最大是 0 dB
    rlim([max(r_min_floor, floor(current_r_limits(1))), r_max_floor]);


    grid on; % 显示网格线

    % 注意：极坐标图 (PolarAxes) 对象不支持 'view' 属性。
end

%% 6. 主程序流程

% 将基础尺寸打包
base_dims = [base_length, base_width, base_height, base_wing_span, base_wing_chord_root, base_wing_chord_tip];

% --- A. 显示初始模型和RCS ---
disp('创建初始模型...');
[initial_vertices, initial_faces] = createFighterModel(initial_params, base_dims);

% 检查初始模型创建是否成功
if isempty(initial_vertices) || isempty(initial_faces) || any(isnan(initial_vertices(:))) || any(isinf(initial_vertices(:)))
    error('Failed to create initial model. Please check initial parameters or model function logic.');
end

% 可视化初始模型
visualizeModel(initial_vertices, initial_faces, '初始隐身战斗机模型');

disp('计算初始模型RCS...');
initial_rcs_linear = zeros(size(rcs_azimuth_angles_deg));
% 计算每个角度的RCS
elevation_rad = deg2rad(rcs_elevation_angle_deg);
for i = 1:length(rcs_azimuth_angles_deg)
    az_deg = rcs_azimuth_angles_deg(i);
    az_rad = deg2rad(az_deg);
    radar_dir = -[cos(elevation_rad) * cos(az_rad), cos(elevation_rad) * sin(az_rad), sin(elevation_rad)];

    rcs_val = calculateRCS(initial_vertices, initial_faces, radar_dir, lambda);

     % Check for non-finite RCS values during calculation
    if ~isfinite(rcs_val)
         warning('Non-finite RCS value encountered during initial calculation at angle %d deg. Setting to 0 for averaging/plotting.', az_deg);
         initial_rcs_linear(i) = 0; % Treat non-finite as zero contribution for average/plotting
    else
        initial_rcs_linear(i) = rcs_val;
    end
end
initial_fitness = mean(initial_rcs_linear); % 计算平均RCS作为初始适应度

% 可视化初始RCS
visualizeRCS(rcs_azimuth_angles_deg, initial_rcs_linear, lambda, '初始模型RCS (水平面, 0-180度方位角)');
fprintf('初始平均RCS (线性值): %f\n', initial_fitness);


% --- B. 使用遗传算法优化 ---
disp('开始遗传算法优化...');

% 定义遗传算法选项
options = optimoptions('ga', ...
    'PopulationSize', 100, ...     % 种群大小
    'MaxGenerations', 50, ...     % 最大代数
    'EliteCount', 5, ...          % 精英个数
    'CrossoverFraction', 0.8, ... % 交叉分数
    'MutationFcn', @mutationadaptfeasible, ... % 自适应变异，适用于有界约束问题
    'Display', 'iter', ...        % 显示迭代过程 (每代显示信息)
    'PlotFcn', @optimplotbestf, ... % <-- 修改了这里的函数名！绘制最佳适应度曲线
    'FunctionTolerance', 1e-6, ... % 适应度函数的停止容差
    'ConstraintTolerance', 1e-6); % 约束的停止容差 (这里只有边界约束)

% 运行遗传算法
% 目标是最小化 fitnessFunction
% ga 语法: ga(fitnessfcn, nvars, Aineq, bineq, Aeq, beq, lb, ub, nonlcon, options)
% 本例中，没有线性不等式、等式约束和非线性约束，只有边界约束 (lb, ub)。
[best_params, min_fitness] = ga(@(params) fitnessFunction(params, base_dims, rcs_azimuth_angles_deg, rcs_elevation_angle_deg, lambda), ...
                                num_params, [], [], [], [], lb, ub, [], options);

disp('遗传算法优化完成.');
fprintf('优化后的最佳参数: ');
disp(best_params);
fprintf('优化后的平均RCS (线性值): %f\n', min_fitness);

% --- C. 显示优化后的模型和RCS ---
disp('创建优化后模型...');
[optimized_vertices, optimized_faces] = createFighterModel(best_params, base_dims);

% 检查优化后模型创建是否成功
if isempty(optimized_vertices) || isempty(optimized_faces) || any(isnan(optimized_vertices(:))) || any(isinf(optimized_vertices(:)))
    error('Failed to create optimized model. Please check optimized parameters or model function logic.');
end

% 可视化优化后模型
visualizeModel(optimized_vertices, optimized_faces, '优化后的隐身战斗机模型');

disp('计算优化后模型RCS...');
optimized_rcs_linear = zeros(size(rcs_azimuth_angles_deg));
elevation_rad = deg2rad(rcs_elevation_angle_deg);
for i = 1:length(rcs_azimuth_angles_deg)
    az_deg = rcs_azimuth_angles_deg(i);
    az_rad = deg2rad(az_deg);
    radar_dir = -[cos(elevation_rad) * cos(az_rad), cos(elevation_rad) * sin(az_rad), sin(elevation_rad)];

    rcs_val = calculateRCS(optimized_vertices, optimized_faces, radar_dir, lambda);

    if ~isfinite(rcs_val)
        warning('Non-finite RCS value encountered during optimized calculation at angle %d deg. Setting to 0 for plotting.', az_deg);
        optimized_rcs_linear(i) = 0; % Treat non-finite as zero for plotting
    else
        optimized_rcs_linear(i) = rcs_val;
    end
end

% 可视化优化后RCS
visualizeRCS(rcs_azimuth_angles_deg, optimized_rcs_linear, lambda, '优化后模型RCS (水平面, 0-180度方位角)');

% --- D. 对比初始和优化后的RCS ---
figure('Name', '初始 vs 优化后 RCS 对比 (相对dB)');
azimuth_rad = deg2rad(rcs_azimuth_angles_deg);

% 将初始RCS转换为相对dB
max_initial_rcs_linear = max(initial_rcs_linear);
if max_initial_rcs_linear < eps
     initial_rcs_dB_rel = -100 * ones(size(initial_rcs_linear)); % Assign a floor
else
    initial_rcs_dB_rel = 10 * log10(initial_rcs_linear / max_initial_rcs_linear + eps); % Relative dB
end

% 将优化后RCS转换为相对dB
max_optimized_rcs_linear = max(optimized_rcs_linear);
if max_optimized_rcs_linear < eps
    optimized_rcs_dB_rel = -100 * ones(size(optimized_rcs_linear)); % Assign a floor
else
    optimized_rcs_dB_rel = 10 * log10(optimized_rcs_linear / max_optimized_rcs_linear + eps); % Relative dB
end

% 确保用于绘图的数据是有限的
finite_indices_initial = isfinite(azimuth_rad) & isfinite(initial_rcs_dB_rel);
finite_indices_optimized = isfinite(azimuth_rad) & isfinite(optimized_rcs_dB_rel);

% 绘制对比极坐标图
polarplot(azimuth_rad(finite_indices_initial), initial_rcs_dB_rel(finite_indices_initial), 'b-', 'LineWidth', 1.5, 'DisplayName', '初始模型');
hold on;
polarplot(azimuth_rad(finite_indices_optimized), optimized_rcs_dB_rel(finite_indices_optimized), 'r-', 'LineWidth', 1.5, 'DisplayName', '优化后模型');

title('初始 vs 优化后模型RCS对比 (相对dB)');
set(gca, 'ThetaDir', 'clockwise', 'ThetaZeroLocation', 'right');
thetaticks(0:45:180);
thetalim([0 180]);

% 统一设置 R轴限制，以便更好地对比
rlim auto; % 先让 MATLAB 自动调整一次范围
current_r_limits = rlim;
r_min_floor = -60; % 设置一个 dB 下限
r_max_floor = 0;  % 设置一个 dB 上限
rlim([max(r_min_floor, floor(current_r_limits(1))), r_max_floor]);


legend show; % 显示图例
grid on;
hold off;

fprintf('\n程序执行完毕。\n');
fprintf('注意：本程序使用高度简化的模型和RCS计算方法，结果仅为概念演示，不能用于实际工程。\n');
fprintf('RCS值是以线性值求平均，可视化时转换为相对dB。优化目标是最小化平均有效散射面积。\n');

%% 辅助函数描述 (已包含在上面)
% createFighterModel: 根据参数生成简化的飞机顶点和面。
% calculateRCS: 使用简化的物理光学方法估算三角形面的线性RCS贡献并求和。
% fitnessFunction: 计算给定参数下飞机在指定角度上的平均RCS（线性值），作为遗传算法的适应度函数。
% visualizeModel: 绘制三维网格模型。
% visualizeRCS: 在极坐标图中绘制RCS随方位角的变化（相对dB）。
% 主程序: 执行参数定义、初始模型/RCS计算及显示、遗传算法优化、优化后模型/RCS计算及显示，并对比结果。