function avg_rcs = rcs_fitness(x)
    % 参数解析
    nose_len = x(1); body_width = x(2); slope_angle = x(3);

    % 角度采样
    theta = linspace(0, pi, 36);  % 俯仰角
    phi = linspace(0, 2*pi, 72);  % 方位角

    [TH, PHI] = meshgrid(theta, phi);
    RCS = zeros(size(TH));

    for i = 1:numel(TH)
        RCS(i) = simulate_rcs(nose_len, body_width, slope_angle, TH(i), PHI(i));
    end

    avg_rcs = mean(RCS(:));  % 平均RCS作为适应度
end
