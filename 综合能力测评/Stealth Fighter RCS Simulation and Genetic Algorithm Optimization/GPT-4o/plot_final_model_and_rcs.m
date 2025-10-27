function plot_final_model_and_rcs(x)
    figure('Name','隐身战斗机三维建模','NumberTitle','off');

    % 参数
    nose_len = x(1);
    body_width = x(2);
    slope = x(3);

    % 机身顶面
    L = 10; H = tan(slope)*body_width/2;
    X = [0, nose_len, L, nose_len];
    Y = [0, body_width/2, 0, -body_width/2];
    Z = [0, H, 0, -H];

    fill3(X,Y,Z,'k','FaceAlpha',0.7); hold on;
    fill3(X,-Y,Z,'k','FaceAlpha',0.7);
    axis equal; grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('简化隐身战斗机模型');

    % 绘制 RCS 极坐标图
    theta = linspace(0, pi, 180);
    phi = pi/2; % 固定方位角
    rcs_vals = zeros(size(theta));
    for i = 1:length(theta)
        rcs_vals(i) = simulate_rcs(nose_len, body_width, slope, theta(i), phi);
    end

    figure('Name','俯仰角方向RCS分布','NumberTitle','off');
    polarplot(theta,10*log10(rcs_vals),'LineWidth',2);
    title('RCS方向性分布 (俯仰角, dBsm)');
end
