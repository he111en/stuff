%% Gavish-Donoho
function [U, S, V, X1, X2] = step3_optimalcutoff(X_roi)
%% STEP 3 — Snapshot matrices + SVD + Gavish-Donoho rank
X1 = X_roi(:,1:end-1); X2 = X_roi(:,2:end);
[U, S, V]  = svd(X1, 'econ');
s          = diag(S);
cumEnergy  = cumsum(s.^2) / sum(s.^2);
[m, n]     = size(X1);
beta       = min(m,n) / max(m,n);
r_GD       = sum(s >= optimal_SVHT_coef(beta,0) * median(s));
fprintf('  GD rank: %d  |  r90=%d  r95=%d  r99=%d\n', r_GD, ...
    find(cumEnergy>=0.90,1), find(cumEnergy>=0.95,1), find(cumEnergy>=0.99,1));
end

