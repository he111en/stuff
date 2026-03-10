%Binary mask (atlas)
function [X_roi, L_atlas] = step2_360roi(v, nx, ny, nz, nt, atlasFile, p)
%% STEP 2 — Glasser ROI extraction + z-score (Casorso approach)
L_atlas = niftiread(niftiinfo(atlasFile));
if ~isequal(size(L_atlas), [nx ny nz]); error('Atlas/fMRI size mismatch.'); end
data  = reshape(v, [nx*ny*nz, nt]);
X_roi = zeros(p.n_roi, nt);
for r = 1:p.n_roi
    X_roi(r,:) = mean(data(L_atlas(:)==r, :), 1);
end
X_roi = zscore(X_roi, 0, 2);   % zero mean, unit variance per ROI ()
fprintf('  ROI timeseries: [%d x %d], z-scored\n', p.n_roi, nt);
end

