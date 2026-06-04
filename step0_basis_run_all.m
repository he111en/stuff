%% run_all.m — Standard DMD, top 12 modes, all conditions
STUDY_PATH = '/Volumes/EXDRIVE/o_information/data/sourcedata';
OUT_PATH   = '/Volumes/EXDRIVE/o_information/data/derivativedata';
ATLAS_FILE = '/Volumes/EXDRIVE/o_information/data/sourcedata/Glasser_MNI_bilateral_NATIVE_VOIinVTCspace.nii.gz';

SUBJ = {'sub-01','sub-03','sub-04','sub-05','sub-06','sub-07','sub-08','sub-09','sub-10'};
SESS = 3;

p.dt_sec   = 1;
p.K_keep   = 12;
p.n_roi    = 360;
p.bin_step = 0.01;

CONDITIONS = struct();
CONDITIONS(1).task = 'rest'; CONDITIONS(1).runs = {'run-01'};
CONDITIONS(2).task = 'phy';  CONDITIONS(2).runs = {'run-01','run-02'};
CONDITIONS(3).task = 'amb';  CONDITIONS(3).runs = {'run-01','run-02','run-03','run-04'};

Phi_cond = cell(1,3);   % [360 x 108] per condition
ts_cond  = cell(3,9);   % ts per condition per subject

for co = 1:numel(CONDITIONS)
    task     = CONDITIONS(co).task;
    RUN      = CONDITIONS(co).runs;
    Phi_all  = [];
    su_count = 0;

    for su = 1:numel(SUBJ)
        subj     = SUBJ{su};
        X_concat = [];

        for ru = 1:numel(RUN)
            run = RUN{ru};
            niiFile = fullfile(STUDY_PATH, subj, ...
                sprintf('%s_task-%s_acq-2depimb4_%s_SCSTBL_3DMCTS_bvbabel_undist_fix_THPGLMF3c_sess-0%d_BBR_bvbabel.nii.gz', ...
                subj, task, run, SESS));
            if ~isfile(niiFile); fprintf('[SKIP] %s | %s | %s\n', subj, task, run); continue; end

            [v, info, nx, ny, nz, nt] = step1_load(niiFile);
            [X_roi, ~]                 = step2_360roi(v, nx, ny, nz, nt, ATLAS_FILE, p);
            X_concat = [X_concat, X_roi(:, 1:end-1)];
        end

        if isempty(X_concat); continue; end
        fprintf('\n===== %s | %s =====\n', subj, task);

        [U, S, Vsvd, X1, X2]    = step3_optimalcutoff(X_concat);
        [Phi, lambda, b, ts]     = step4_dmd(U, S, Vsvd, X1, X2, p);

        Phi_all  = [Phi_all, Phi];
        su_count = su_count + 1;
        ts_cond{co, su_count} = ts;   % save ts per condition per subject
    end

    Phi_cond{co} = Phi_all;
    fprintf('\nFinished %s — %d subjects stored.\n', task, su_count);
end

%% Step 8 — O-information per condition (separate figure per condition)
step8_oinfo_conditions(ts_cond, CONDITIONS, SUBJ);