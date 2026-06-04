function step11_synergy_mask(CONDITIONS, SUBJ, ATLAS_FILE, STUDY_PATH, SESS, p, OUT_PATH)
%% STEP 11 — Binary NIfTI mask of most synergistic multiplet at k_min
%
% For each subject x condition:
%   1. Runs O-information on A+B parcels (loads from saved results if available)
%   2. Finds the most synergistic multiplet at k_min
%   3. Creates a [360] binary vector (1 = parcel in multiplet, 0 = not)
%   4. Maps back to voxel space and saves as NIfTI

%% Parcel sets
parcel_ids = [10,96,190,276,48,49,50,95,117,144,228,229,230,275,297,324, ...
              23,156,157,16,21,203,196,201,336,337, ...
              84,149,264,329];
n_parcels = numel(parcel_ids);

%% Load  results
save_path = fullfile(OUT_PATH, 'oinfo_results.mat');
if isfile(save_path)
    load(save_path, 'results');
    fprintf('Loaded results from %s\n', save_path);
else
    error('No saved results found at %s — run step9 first.', save_path);
end

%% Load atlas for voxel mapping
fprintf('Loading atlas...\n');
atlas_nii = niftiread(ATLAS_FILE);
atlas_info = niftiinfo(ATLAS_FILE);
[nx, ny, nz] = size(atlas_nii);
L_atlas = atlas_nii;

%% Loop conditions and subjects
n_cond = numel(CONDITIONS);
for co = 1:n_cond
    task = CONDITIONS(co).task;
    RUN  = CONDITIONS(co).runs;

    outDir = fullfile(OUT_PATH, sprintf('synergy_masks_%s', task));
    if ~exist(outDir,'dir'); mkdir(outDir); end

    fprintf('\n=== Synergy masks: %s ===\n', task);

    for su = 1:numel(SUBJ)
        subj       = SUBJ{su};
        field_name = sprintf('%s_%s', strrep(subj,'-','_'), task);

        if ~isfield(results, field_name)
            fprintf('  [SKIP] %s | %s — no saved results\n', subj, task);
            continue;
        end

        r     = results.(field_name);
        k_min = r.k_min;
        Otot  = r.Otot;

        %% extract most synergistic multiplet  k_min
        if ~isfield(Otot(k_min),'sorted_syn') || isempty(Otot(k_min).sorted_syn)
            fprintf('  [SKIP] %s | %s — no synergistic multiplet at k=%d\n', subj, task, k_min);
            continue;
        end

        C_kmin    = nchoosek(1:n_parcels, k_min); % reconstructs all combos of k_min
        best_idx  = Otot(k_min).index_syn(1);         % row index of most synergistic combo in that matrix
        best_combo = parcel_ids(C_kmin(best_idx, :)); % convertion of actual parcel IDs
        best_O    = Otot(k_min).sorted_syn(1);

        fprintf('  %s | %s: k_min=%d | O=%.4f | parcels=%s\n', ...
            subj, task, k_min, best_O, mat2str(best_combo));

        %%  [360] binary mask
        mask_360 = zeros(360, 1, 'int32');
        mask_360(best_combo) = 1;
% A vector of 360 zeros. The parcel positions of the synergistic multiplet get set to 1.

        %% Map to voxel space
        vol = zeros(nx, ny, nz, 'int32');
        for r_idx = 1:360
            vol(L_atlas == r_idx) = mask_360(r_idx);
        end
% For each parcel, find all voxels belonging to it and set them to 0 or 1. 
% So all voxels in parcel 324 get value 1, all others stay 0.
        %% Save NIfTI
        ri = atlas_info;
        ri.Datatype = 'int32';
        ri.ImageSize = [nx ny nz];
        ri.raw.dim(1) = 3;
        ri.raw.dim(2:4) = [nx ny nz];
        ri.raw.dim(5:8) = 1;
        ri.raw.bitpix = 32;
        ri.raw.datatype = 8;

        fname = fullfile(outDir, sprintf('%s_%s_kmin%d_synmask.nii', subj, task, k_min));
        niftiwrite(vol, fname, ri, 'Compressed', true);
        fprintf('    Saved → %s\n', fname);
    end
end
end
