
function err = kd_rgb_cost(Kd, RGB_calculated, depths_flat, Rho, E0, SR, SG, SB, lambda)

nSamples = size(RGB_calculated, 1);  % number of RGB rows = # samples
predicted_RGB = zeros(nSamples, 3);

% === Predict RGB for each sample ===
delta_lambda = lambda(2) - lambda(1);  % assuming uniform spacing
for i = 1:nSamples
    rho = Rho(i,:)';              % reflectance spectrum for this sample (column vector)
    depth = depths_flat(i);       % corresponding depth for this sample

    attenuation = exp(-Kd .* depth);     % attenuation vector over wavelengths
    spectrum = rho .* E0 .* attenuation; % effective spectrum at sensor

    % Integrate over spectral response curves
    predicted_RGB(i,1) = sum(SR .* spectrum) * delta_lambda; % Red Riemann sum for integration 
    predicted_RGB(i,2) = sum(SG .* spectrum) * delta_lambda; % Green Riemann sum for integration 
    predicted_RGB(i,3) = sum(SB .* spectrum) * delta_lambda; % Blue Riemann sum for integration 
end

% === Core RGB squared error ===
% rgb_error = sum((RGB_calculated - predicted_RGB).^2, 'all'); % RGB_calculated comes from Jerlovs water type, predicted_RGB is simulated
% === Core error: Cosine angular distance ===
dot_product = sum(RGB_calculated .* predicted_RGB, 2);                % dot for each row
norm_measured = sqrt(sum(RGB_calculated.^2, 2));                      % norm for each row
norm_predicted = sqrt(sum(predicted_RGB.^2, 2));                      % norm for each row

% Avoid division by zero
epsilon = 1e-8;
cos_theta = dot_product ./ (norm_measured .* norm_predicted + epsilon);
cos_theta = max(min(cos_theta, 1), -1);  % Clamp to avoid NaNs

angles = acos(cos_theta);  % in radians
rgb_error = sum(angles.^2);  % squared angular distance

% === Optional: Penalty for Kd bounds violation ===
lower_bound = 0;
upper_bound = 1;
penalty_bounds = sum((Kd(Kd < lower_bound) - lower_bound).^2) + ...
                 sum((Kd(Kd > upper_bound) - upper_bound).^2);
penalty_weight_bounds = 1e3;

% === Optional: Smoothness penalty (second derivative of Kd) ===
smoothness_penalty = sum(diff(Kd,2).^2);
%penalty_weight_smooth = 1e-1;
penalty_weight_smooth = 1e3;
% === Total error to minimize ===
err = rgb_error + ...
      penalty_weight_bounds * penalty_bounds + ...
      penalty_weight_smooth * smoothness_penalty;

% === DEBUG PLOT every 10 iterations ===
persistent iter_count
if isempty(iter_count)
    iter_count = 1;
else
    iter_count = iter_count + 1;
end

if mod(iter_count, 10) == 0 || iter_count <= 3
    clf;
    subplot(1,2,1);
    plot(lambda, Kd, 'r-', 'LineWidth', 2);
    xlabel('Wavelength (nm)'); ylabel('Kd(λ) [1/m]');
    title(sprintf('Iteration %d: Estimated Kd(λ)', iter_count));
    grid on;

    subplot(1,2,2);
    bar([RGB_calculated; predicted_RGB]);
    title('Measured vs Predicted RGB (all samples)');
    legend('R','G','B');
    xlabel('Sample Index');
    ylabel('RGB Value');
    drawnow;
end

end
