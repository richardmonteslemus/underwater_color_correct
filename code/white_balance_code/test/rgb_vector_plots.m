% % Clear the workspace and figure
% %clear; clc; close all;
% 
% % Define two RGB vectors (not normalized)
% v1 = [0.3, 0.5, 0.2];  % brownish-green direction
% v2 = [0.2, 0.2, 0.6];  % bluish direction
% 
% v1 = v1 / norm(v1);
% v2 = v2 / norm(v2);
% 
% % Set up 3D plot
% figure;
% quiver3(0, 0, 0, v1(1), v1(2), v1(3), 0, 'r', 'LineWidth', 2); hold on;
% quiver3(0, 0, 0, v2(1), v2(2), v2(3), 0, 'b', 'LineWidth', 2);
% grid on;
% 
% % Set axis limits and labels
% axis equal;
% xlim([0 1]); ylim([0 1]); zlim([0 1]);
% xlabel('Red'); ylabel('Green'); zlabel('Blue');
% title('3D RGB Vector Visualization');
% 
% legend('Vector 1 (reddish-green)', 'Vector 2 (bluish)', 'Location', 'best');
% 
% % Enable 3D rotation
% rotate3d on;
% Clear previous figures
% clear; clc; close all;

% Define two RGB vectors
v1 = [0.3, 0.5, 0.2];  % reddish-green
v2 = [0.2, 0.2, 0.6];  % bluish

% Normalize using Euclidean norm
% 

v1 = v1 / norm(v1); 
v2 = v2 / norm(v2);

% Calculate angle between them
cos_theta = dot(v1, v2) / (norm(v1) * norm(v2));
theta_rad = acos(cos_theta);
theta_deg = rad2deg(theta_rad);

% Set up 3D plot
figure;
quiver3(0, 0, 0, v1(1), v1(2), v1(3), 0, 'r', 'LineWidth', 2); hold on;
quiver3(0, 0, 0, v2(1), v2(2), v2(3), 0, 'b', 'LineWidth', 2);

% Draw a line connecting vector tips to show angle visually
plot3([v1(1), v2(1)], [v1(2), v2(2)], [v1(3), v2(3)], 'k--', 'LineWidth', 1.5);

% Add angle label at midpoint between tips
midpoint = (v1 + v2) / 2;
text(midpoint(1), midpoint(2), midpoint(3), ...
     sprintf('\\theta = %.2f^\\circ', theta_deg), ...
     'FontSize', 12, 'BackgroundColor', 'w');

% Set plot appearance
axis equal;
xlim([0 1]); ylim([0 1]); zlim([0 1]);
xlabel('Red'); ylabel('Green'); zlabel('Blue');
title('3D Angle Between Two RGB Vectors');
legend('Vector 1 (reddish-green)', 'Vector 2 (bluish)', 'Angle', 'Location', 'best');
grid on;

% Enable interactive 3D rotation
rotate3d on;
