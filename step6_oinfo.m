function [kplot, Omin_plot, Omax_plot, k_min, k_cutoff, O_info_min] = step6_oinfo(ts, p)
%% STEP 6 — O-information (maxsize=6 hardcoded in exhaustive_loop_zerolag)
fprintf('  Computing O-information (k=3 to 6)...\n');
Otot = exhaustive_loop_zerolag(ts);

kvals = 3:6;
Omega_max = nan(1,4); Omega_min = nan(1,4);
for ii = 1:4
    k = kvals(ii);
    if ~isempty(Otot(k).sorted_red); Omega_max(ii) = Otot(k).sorted_red(1); end
    if ~isempty(Otot(k).sorted_syn); Omega_min(ii) = Otot(k).sorted_syn(1); end
end

valid = ~isnan(Omega_min);
kplot = kvals(valid); Omin_plot = Omega_min(valid); Omax_plot = Omega_max(valid);

[O_info_min, idx] = min(Omin_plot); k_min = kplot(idx);
cross = find(Omin_plot(idx:end) >= 0, 1);
k_cutoff = NaN; if ~isempty(cross); k_cutoff = kplot(idx+cross-1); end
fprintf('  O_min=%.4f at k=%d', O_info_min, k_min);
if ~isnan(k_cutoff); fprintf('  |  k_cutoff=%d', k_cutoff); end; fprintf('\n');
end