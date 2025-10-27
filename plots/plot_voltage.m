function plot_voltage(v_homogenous, v_traget, v_diff)
% PLOT_VOLTAGE Plot voltages for homogeneous, target, and their difference.
%
% Inputs:
%   v_homogenous - Voltage vector of the empty tank.
%   v_traget     - Voltage vector of the tank with object(s). (Note: name kept for compatibility.)
%   v_diff       - Difference vector (v_traget - v_homogenous).

h = figure();
h.WindowState = 'maximized';
set(gca,'FontSize',30)

pause(1)
yyaxis left
plot(v_homogenous, 'LineWidth', 3, 'Color', 'b')
hold on
plot(v_traget, 'LineWidth', 3, 'LineStyle', ':', 'Color', 'g')

ylabel('Voltage (V)', 'FontSize', 30);
yyaxis right
plot(v_diff .* 10^3, 'LineWidth', 3)
legend('Empty tank', 'Tank with an object', 'Difference', 'FontSize', 30)
xlim([1, length(v_traget)])
title('Voltage measurements', 'FontSize', 40)
ylabel('Voltage (mV)', 'FontSize', 30);
xlabel('Measurements', 'FontSize', 30);

end