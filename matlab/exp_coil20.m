addpath(genpath(fullfile('..\','utility')));

%%pca
pca = 0;
if pca,
    [pc,sdata,latent] = princomp(data);
    latent_sum = 0;
    for dim = 1:length(latent),
        latent_sum = latent_sum + latent(dim);
        if latent_sum/sum(latent) >= 0.98,
            break;
        end
    end
    data = sdata(:,1:dim);
end

%coil 20 K
K = [4 8 12 16 20];

[data,tlabel] = process_data_tlabel(data,tlabel);

km_opt.km_iter = 30;
km_opt.km_replica = 10;
%lambda is shared by both l1graph and smce
lambda = 0.1; lambda_l0graph = 0.01; maxIter_l1graph_admm = 7000; maxIter_l0graph = 100; 
smce_kmax=15; omp_Ts = [3 4 5];

%parameters for regularization
reg_weight = 0.1; naive_rl1graph_knn = 5; l0l1_knn = 5;
maxSingleIter_l0l1graph = 30; maxIter_l0l1graph = 5; maxIter_naive_rl1 = 5;

%use cuda?
use_cuda = 1;

test_reg = 0;


nK = length(K);
perf_coil20 = cell(1,nK);
for i = 1:nK,
    k = K(i);
    [data_k_class,tlabel_k_class]  = choose_k_class(data,tlabel,k);
    
    [perf_coil20{i},l1graph_alpha,l0graph_alpha] = run_perf_comp(data_k_class,k,tlabel_k_class,km_opt,lambda,lambda_l0graph,maxIter_l1graph_admm,maxIter_l0graph,smce_kmax,omp_Ts,...
                                                    reg_weight,naive_rl1graph_knn,l0l1_knn,smce_kmax,maxSingleIter_l0l1graph,maxIter_l0l1graph,maxIter_naive_rl1,use_cuda,test_reg);

    fprintf('coil120 %d cluster result: \n', i);
    perf_coil20{i}
end

%[perf,l1graph_alpha,l0graph_alpha] = run_perf_comp(data,k,tlabel,km_opt,lambda,lambda_l0graph,maxIter_l0graph,smce_kmax,omp_T);
    



