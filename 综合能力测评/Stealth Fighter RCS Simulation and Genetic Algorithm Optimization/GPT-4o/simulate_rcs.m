function rcs = simulate_rcs(nose_len, body_width, slope_angle, theta, phi)
    % 简化模型：金字塔状结构体模拟隐身外形
    % 近似使用物理光学法计算雷达反射截面

    % 有效反射面积近似为某个方向上的投影面积乘以雷达波反射因子
    k = 2*pi / 0.03;  % 波数，假设雷达波长3cm
    normal = [sin(slope_angle), 0, cos(slope_angle)];

    incident = [sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta)];

    % 简单镜面反射条件，返回强度估算
    dot_val = abs(dot(incident, normal));
    if dot_val < 0.1
        rcs = 0.01; % 几乎无反射
    else
        projected_area = nose_len * body_width * abs(dot_val);
        rcs = (projected_area^2) / (4*pi);
    end
end
