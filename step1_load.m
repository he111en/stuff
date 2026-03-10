function [v, info, nx, ny, nz, nt] = step1_load(niiFile)
%% STEP 1 — Load NIfTI
info = niftiinfo(niiFile); v = double(niftiread(info));
[nx, ny, nz, nt] = size(v);
fprintf('  Loaded: [%d %d %d] x %d TRs\n', nx, ny, nz, nt);
end
