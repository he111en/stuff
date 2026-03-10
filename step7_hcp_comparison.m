unction step7_hcp_comparison(SUBJ, all_damp, all_nrelax, all_freq)
% STEP 7 — Summary comparison against Casorso et al. (2019)
%
%  reference values (group-level, 730 HCP subjects, TR=0.72s):
%   Mode 1: purely real relaxator, Delta = 7.27 s
%   Mode 2: purely real relaxator, Delta = 5.87 s
%   Mode 3: first oscillator,      Delta = 5.36 s, T = 549 s (0.002 Hz)
%   ~2 relaxators in top 12 modes

casorso_damp    = [7.27, 5.87, 5.36];   % top 3 damping times
casorso_nrelax  = 2;                     % relaxators in top modes
n_subj          = numel(SUBJ);
K               = size(all_damp, 2);
subj_labels     = strrep(SUBJ, 'sub-', 'S');

figure('Position', [100 100 1300 500]);

% 1 — Damping time profiles per subject vs Casorso
subplot(1,3,1); hold on; box on;
cmap = lines(n_subj);
for s = 1:n_subj
    plot(1:K, all_damp(s,:), '-o', 'Color', cmap(s,:), 'MarkerSize', 3, ...
        'DisplayName', subj_labels{s});
end
yline(7.27, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Casorso M1 (7.27s)');
yline(5.87, 'k:',  'LineWidth', 1.5, 'DisplayName', 'Casorso M2 (5.87s)');
xlabel('Mode rank'); ylabel('Damping time (s)');
title('Damping time profile'); legend('Location','northeast','FontSize',7);
xlim([1 K]); ylim([0 max(all_damp(:))*1.1]);

%l 2 — Number of relaxators per subject vs Casorso
subplot(1,3,2); hold on; box on;
b = bar(1:n_subj, all_nrelax, 'FaceColor', [0.4 0.6 0.8]);
yline(casorso_nrelax, 'k--', 'LineWidth', 1.5, 'DisplayName', sprintf('Casorso (%d)', casorso_nrelax));
set(gca, 'XTick', 1:n_subj, 'XTickLabel', subj_labels, 'XTickLabelRotation', 45);
ylabel('Number of relaxators (top 20)');
title('Relaxators vs Casorso'); legend('Location','northeast');
ylim([0 max(all_nrelax)+2]);

% 3 — Frequency distribution of oscillator modes
subplot(1,3,3); hold on; box on;
all_freq_flat = all_freq(all_freq > 0);   % positive frequencies only
histogram(all_freq_flat, 20, 'FaceColor', [0.4 0.6 0.8], 'EdgeColor','w');
xline(0.002, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Casorso M3 (0.002 Hz)');
xline(0.05,  'r--', 'LineWidth', 1.5, 'DisplayName', 'DMN upper bound (0.05 Hz)');
xlabel('Frequency (Hz)'); ylabel('Count');
title('Oscillator frequency distribution'); legend('Location','northeast');

sgtitle('DMD benchmark: all subjects vs Casorso et al. (2019)', 'FontSize', 12);
end