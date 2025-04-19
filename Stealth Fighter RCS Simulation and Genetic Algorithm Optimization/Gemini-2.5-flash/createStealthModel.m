% createStealthModel.m
% 根据参数创建简化的隐身战斗机模型 (多面体)
% H_bottom 固定为 0
% 返回两种格式的面数据：用于patch的数值矩阵和用于RCS计算的cell数组

function [vertices, faces_patch_matrix, normals, areas, centroids, faces_cell] = createStealthModel(params)

% 参数解析
L = params(1);          % 长度
W_tail = params(2);     % 尾部宽度
H_tail = params(3);     % 尾部高度 (顶部)
x_mid_frac = params(4); % 最大宽度/高度位置比例
W_mid = params(5);      % 最大宽度
H_mid_top = params(6);  % 最大高度 (顶部)
H_bottom = 0;           % 底部高度固定为0

x_mid = L * x_mid_frac;

% 定义顶点 (9个顶点)
% 顶点顺序对面的定义很重要
vertices = [
    0, 0, 0;                                % 1: Nose tip
    L, W_tail/2, H_tail;                    % 2: Tail top-right
    L, -W_tail/2, H_tail;                   % 3: Tail top-left
    L, -W_tail/2, H_bottom;                 % 4: Tail bottom-left
    L, W_tail/2, H_bottom;                  % 5: Tail bottom-right
    x_mid, W_mid/2, H_mid_top;              % 6: Mid top-right
    x_mid, -W_mid/2, H_mid_top;             % 7: Mid top-left
    x_mid, -W_mid/2, H_bottom;              % 8: Mid bottom-left
    x_mid, W_mid/2, H_bottom;               % 9: Mid bottom-right
];

% 定义面 (使用顶点索引) - 使用 cell 数组方便定义不同顶点数的面
% 顶点顺序应保持一致 (例如，逆时针看表面法线朝外)
faces_cell = {
    [9 8 4 5],      % Bottom (Quad)
    [1 6 7],        % Top-Front (Tri)
    [6 7 3 2],      % Top-Back (Quad)
    [1 9 6],        % Side-Right-Front (Tri)
    [9 5 2 6],      % Side-Right-Back (Quad)
    [1 7 8],        % Side-Left-Front (Tri)
    [7 3 4 8],      % Side-Left-Back (Quad)
    [2 3 4 5]       % Tail (Quad)
};

% 计算每个面的法向量、面积和质心
num_faces = length(faces_cell);
normals = zeros(num_faces, 3);
areas = zeros(num_faces, 1);
centroids = zeros(num_faces, 3);

for i = 1:num_faces
    face_verts_idx = faces_cell{i};
    face_verts = vertices(face_verts_idx, :);

    % 计算质心 (顶点平均值)
    centroids(i, :) = mean(face_verts, 1);

    % 计算法向量和面积
    if size(face_verts, 1) == 3 % Triangle
        v1 = face_verts(2,:) - face_verts(1,:);
        v2 = face_verts(3,:) - face_verts(1,:);
        n = cross(v1, v2);
        areas(i) = 0.5 * norm(n);
        normals(i, :) = n / norm(n); % Normalize
    elseif size(face_verts, 1) == 4 % Quadrilateral (approximate as two triangles)
        % Use two triangles to get normal and area
        v1 = face_verts(2,:) - face_verts(1,:);
        v2 = face_verts(4,:) - face_verts(1,:); % Diagonal
        n1 = cross(v1, v2); % Normal for triangle 1-2-4
        area1 = 0.5 * norm(n1);

        v3 = face_verts(3,:) - face_verts(2,:);
        v4 = face_verts(4,:) - face_verts(2,:);
        n2 = cross(v3, v4); % Normal for triangle 2-3-4
        area2 = 0.5 * norm(n2);

        % Average normal and total area
        n = n1 + n2; % Sum of unnormalized normals
        areas(i) = area1 + area2;
        normals(i, :) = n / norm(n); % Normalize
    else
        % Handle other polygon types if necessary, or skip
        normals(i, :) = [NaN, NaN, NaN];
        areas(i) = NaN;
        centroids(i, :) = [NaN, NaN, NaN];
        continue; % Skip this face
    end

    % 确保法向量朝外 (检查与从原点到质心的向量的点积)
    % 对于这个特定模型，原点在鼻尖，大部分质心x>0。
    % 检查与从鼻尖到质心的向量的点积
    vec_to_centroid = centroids(i,:) - vertices(1,:); % Vector from nose tip to centroid
    if dot(normals(i,:), vec_to_centroid) < 0
         % If dot product is negative, normal points inwards, flip it
         normals(i,:) = -normals(i,:);
    end
    % Special case: Bottom face normal should point down (negative Z)
    % Assuming bottom face is the first one defined
    if i == 1
        if normals(i,3) > 0
            normals(i,:) = -normals(i,:);
        end
    end
end

% Remove faces with NaN normal/area if any were skipped
valid_faces_idx = ~any(isnan(normals), 2);
faces_cell = faces_cell(valid_faces_idx);
normals = normals(valid_faces_idx, :);
areas = areas(valid_faces_idx);
centroids = centroids(valid_faces_idx, :);

% --- 生成用于 patch 函数的数值矩阵格式的面数据 ---
num_valid_faces = length(faces_cell);
if num_valid_faces == 0
    faces_patch_matrix = []; % No valid faces
else
    % 找到最大顶点数
    max_verts_per_face = max(cellfun(@length, faces_cell));
    % 初始化数值矩阵，用 NaN 填充
    faces_patch_matrix = NaN(num_valid_faces, max_verts_per_face);
    % 填充矩阵
    for i = 1:num_valid_faces
        face_verts_idx = faces_cell{i};
        faces_patch_matrix(i, 1:length(face_verts_idx)) = face_verts_idx;
    end
end

end