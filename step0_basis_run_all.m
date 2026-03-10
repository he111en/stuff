% run_all.m — DMD + O-information 
STUDY_PATH = '/Volumes/EXDRIVE/o_information/data/sourcedata';
OUT_PATH = '/Volumes/EXDRIVE/o_information/data/derivativedata';
ATLAS_FILE = '/Volumes/EXDRIVE/o_information/data/sourcedata/Glasser_MNI_bilateral_NATIVE_VOIinVTCspace.nii';

SUBJ = {'sub-01','sub-03','sub-04','sub-05','sub-06','sub-07','sub-08','sub-09','sub-10'};
TASK = {'rest'}; %'phy','amb',
SESS = 3;

p.dt_sec        = 1;    % TR in seconds
p.r_model       = 114;  % SVD truncation rank
p.K_keep        = 20;   % DMD modes to retain
p.maxsize_oinfo = 12;   % max O-information interaction order
p.n_roi         = 360;  % Glasser parcels

rest_subj = {}; rest_damp = []; rest_nrelax = []; rest_freq = [];
for su = 1:numel(SUBJ)
    subj = SUBJ{su};
    for ta = 1:numel(TASK)
        task = TASK{ta};
        niiFile = fullfile(STUDY_PATH, subj, ...
    sprintf('%s_task-%s_acq-2depimb4_run-01_SCSTBL_3DMCTS_bvbabel_undist_fix_THPGLMF3c_sess-0%d_BBR_bvbabel.nii.gz', ...
    subj, task, SESS));
        if ~isfile(niiFile); fprintf('[SKIP] %s | %s\n', subj, task); continue; end
        fprintf('\n===== %s | %s =====\n', subj, task);

        [v, info, nx, ny, nz, nt]             = step1_load(niiFile);
        [X_roi, L_atlas]                       = step2_360roi(v, nx, ny, nz, nt, ATLAS_FILE, p);
        [U, S, Vsvd, X1, X2]                  = step3_optimalcutoff(X_roi);
        [Phi, lambda, freq, damp, b, ts]       = step4_dmd(U, S, Vsvd, X1, X2, p);
        step5_export(Phi, lambda, freq, damp, b, L_atlas, nx, ny, nz, info, subj, task, p, OUT_PATH);
        [kplot, Omin_plot, Omax_plot, k_min, k_cutoff, O_info_min] = step6_oinfo(ts, p);
        step8_synergyvsredundancy_plotcurve(kplot, Omin_plot, Omax_plot, k_min, k_cutoff, O_info_min, subj, task, p);
    end
end
%% Step 7 — Casorso comparison (rest only, runs after all subjects)
if ~isempty(rest_subj)
    step7_hcp_comparison(rest_subj, rest_damp, rest_nrelax, rest_freq);
end