function [Phi, lambda, freq, damp, b, ts] = step4_dmd(U, S, V, X1, X2, p)
% STEP 4 — DMD + mode ordering by damping time  Δ( ie Casorso et al. 2019)
% Relaxator: Im(lambda)/|lambda| < 0.01  → infinite period, pure decay
% Oscillator: complex eigenvalue          → oscillates at freq = Im(mu)/2pi

Ur = U(:,1:p.r_model); Sr = S(1:p.r_model,1:p.r_model); Vr = V(:,1:p.r_model);
[W, Lambda]  = eig(Ur' * X2 * Vr / Sr);
lambda_all   = diag(Lambda);
Phi_all      = real(X2 * (Vr / Sr) * W);
b_all        = pinv(Phi_all) * X1(:,1);
mu_all       = log(lambda_all) / p.dt_sec;
freq_all     = imag(mu_all) / (2*pi);
damp_all     = -p.dt_sec ./ log(abs(lambda_all));

% Order by damping time — most persistent first
d = damp_all; d(~(isfinite(d) & d>0)) = -Inf;
[~, idx] = sort(d, 'descend');
keep     = idx(1:p.K_keep);

Phi = Phi_all(:,keep); lambda = lambda_all(keep);
freq = freq_all(keep); damp = damp_all(keep); b = b_all(keep);

is_relax = abs(imag(lambda))./abs(lambda) < 0.01;
fprintf('  Relaxators: %d  |  Oscillators: %d  |  Damp range: %.1f–%.1f s\n', ...
    sum(is_relax), sum(~is_relax), min(damp), max(damp));

% DMD state trajectories [nt-1 x K_keep]
t  = 0:size(X1,2)-1;
ts = real(cell2mat(arrayfun(@(k) (lambda(k).^t * b(k)).', 1:p.K_keep, 'UniformOutput',false)));
end
