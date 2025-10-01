% Load the Kd data (rows = wavelengths, columns = Jerlov types)
kd_data = readmatrix('Jerlov_kd.csv');  % Size: [31 x 8]

% Define wavelength vector (assuming 400 to 700 nm at 10 nm intervals)
lambda = linspace(400, 700, size(kd_data, 1));  % [1 x 31]

% Plot Kd curves for all 8 Jerlov types
figure;
plot(lambda, kd_data, 'LineWidth', 2);  % plots each column as a line
xlabel('Wavelength (nm)');
ylabel('Kd (\lambda) [1/m]');
title('Diffuse Attenuation Coefficient (Kd) for Jerlov Water Types');
legend({'I', 'IA', 'IB', 'II', 'III', '1', '3', '5'}, 'Location', 'northwest');
grid on;
