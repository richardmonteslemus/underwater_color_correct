function err = kd_rgb_cost_parametric(p, RGB_measured, depths, rho, E0, SR, SG, SB, lambda)
    Kd = p(1) + p(2) * exp(-0.5 * ((lambda - p(3)) ./ p(4)).^2);
    nDepths = length(depths);
    predicted_RGB = zeros(nDepths, 3);

    for i = 1:nDepths
        d = depths(i);
        attenuation = exp(-Kd * d);
        L = rho .* E0 .* attenuation;

        predicted_RGB(i,1) = sum(SR .* L);
        predicted_RGB(i,2) = sum(SG .* L);
        predicted_RGB(i,3) = sum(SB .* L);
    end

    err = sum((RGB_measured - predicted_RGB).^2, 'all');
end
