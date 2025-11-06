clear; clc; rng(1);

N = 500; D = 68;
X = copnorm (rand(N,D));

max_k = 4;
save_every = 1;
elapsed = zeros(1,max_k - 2);
for k = 3:max_k
    fprintf('\n=== Running k = %d ===\n', k);
    C = nchoosek(1:D, k);
    nComb = size(C,1);
    fprintf('Total combinations: %d\n', nComb);

    Ovals = zeros(nComb,1);
    t0k = tic;

    try
        for i = 1:nComb
            t0i = tic;
            Ovals(i) = o_information_boot(X, 1:N, C(i,:));
            fprintf('k=%d | combo %d/%d | elapsed %.7fs\n', k, i, nComb, toc(t0i));
        end
        elapsed(k-2) = toc(t0k);
        fprintf('Completed k=%d in %.2f seconds.\n', k, elapsed);
    catch ME
        elapsed(k-2) = toc(t0k);
        fprintf('Crash at k=%d after %.2f seconds (%d/%d combos)\n', k, elapsed, i, nComb);
        fprintf('Error: %s\n', ME.message);
        save(sprintf('crash_recovery_k%d.mat', k), 'k','i','nComb','Ovals','elapsed','-v7.3');
        rethrow(ME);
    end

    if mod(k, save_every)==0
        save(sprintf('checkpoint_k%d.mat', k), 'k','nComb','Ovals','elapsed','-v7.3');
    end
end
if exist('elapsed','var')
    loadData = dir('checkpoint_k*.mat');
    k_vals = zeros(length(loadData),1);
    time_vals = zeros(length(loadData),1);

    for i = 1:length(loadData)
        s = load(loadData(i).name);
        k_vals(i) = s.k;
        time_vals(i) = s.elapsed;
    end

end
