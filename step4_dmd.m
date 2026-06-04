function [Phi, lambda, b, ts] = step4_dmd(U, S, V, X1, X2, p)
%% STEP 4 — Standard DMD, top 12 modes in natural eigenvalue order

Ur = U(:, 1:size(S,1));
Sr = S;
Vr = V(:, 1:size(S,1));

Atilde      = Ur' * X2 * Vr / Sr;
[W, Lambda] = eig(Atilde);

Phi    = real(X2 * (Vr / Sr) * W);
lambda = diag(Lambda);

%% Keep top K_keep in natural order
Phi    = Phi(:, 1:p.K_keep);
lambda = lambda(1:p.K_keep);

%% Initial amplitudes
b = pinv(Phi) * X1(:,1);   % [K_keep x 1]

%% DMD state trajectories [T x K_keep]
T  = size(X1, 2);
t  = 0:T-1;
ts = zeros(T, p.K_keep);
for k = 1:p.K_keep
    ts(:,k) = real((lambda(k).^t) * b(k)).';
end

%% Print mode table
fprintf('\n  Top %d eigenvalues (natural DMD ordering):\n', p.K_keep);
for k = 1:p.K_keep
    mu   = log(lambda(k)) / p.dt_sec;
    freq = imag(mu) / (2*pi);
    damp = -p.dt_sec / log(abs(lambda(k)));
    fprintf('  Mode %d  |lambda|=%.4f  freq=%.4f Hz  damp=%.2f s\n', ...
        k, abs(lambda(k)), freq, damp);
end
end