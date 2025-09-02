function check_coded_exe_obs_corr(subj_ids, conditions)

clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};

[included_subjects excluded_subjects]=exclude_subjects(subj_ids, conditions, '', '.nomove.interp');

cluster_mu_erds=zeros(length(clusters),length(conditions),length(included_subjects));
subj_exes=zeros(length(conditions),length(included_subjects));
for i=1:length(clusters)
    clusters(i).mu_erds=dict;
    clusters(i).mu_mean_erds=dict;
    for k=1:length(conditions)
        for j=1:length(included_subjects)
            subj_id=included_subjects(j);
            data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) '/' num2str(subj_id) '.' conditions{k}  '.nomove.interp.set']);
            [times x cluster_mu_erds(i,k,j)]=cluster_erd(data, clusters(i).channels, [6 9], [2 30], [100 700], [750 1500]);                                             
            try
                data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) '/' num2str(subj_id) '.' conditions{k}  '.move.interp.set']);
                subj_exes(k,j)=data.trials;
            catch
            end
        end        
    end
end

for c=1:length(conditions)
    figure();
    plot(subj_exes(c,:),squeeze(cluster_mu_erds(1,c,:)),'o');
    xlabel(sprintf('Number %s execution', conditions{c}));
    ylabel(sprintf('C3 mu ERD: %s', conditions{c}));
    [rho,p]=corr(subj_exes(c,:)',squeeze(cluster_mu_erds(1,c,:)),'type','Spearman');
    disp(sprintf('C3 %s: rho=%.3f, p=%.3f', conditions{c}, rho, p));

    figure();
    plot(subj_exes(c,:),squeeze(cluster_mu_erds(2,c,:)),'o');
    xlabel(sprintf('Number %s execution', conditions{c}));
    ylabel(sprintf('C4 mu ERD: %s', conditions{c}));
    [rho,p]=corr(subj_exes(c,:)',squeeze(cluster_mu_erds(2,c,:)),'type','Spearman');
    disp(sprintf('C4 %s: rho=%.3f, p=%.3f', conditions{c}, rho, p));

    figure();
    plot(subj_exes(c,:),squeeze(mean(cluster_mu_erds(:,c,:),1)),'o');
    xlabel(sprintf('Number %s execution', conditions{c}));
    ylabel(sprintf('C mu ERD: %s', conditions{c}));
    [rho,p]=corr(subj_exes(c,:)',squeeze(mean(cluster_mu_erds(:,c,:),1)),'type','Spearman');
    disp(sprintf('C %s: rho=%.3f, p=%.3f', conditions{c}, rho, p));

end

figure();
plot(sum(subj_exes,1), squeeze(mean(cluster_mu_erds(1,:,:),2)),'o');
xlabel('Number executions');
ylabel('C3 mu ERD');
[rho,p]=corr(sum(subj_exes,1)',squeeze(mean(cluster_mu_erds(1,:,:),2)),'type','Spearman');
disp(sprintf('C3: rho=%.3f, p=%.3f', rho, p));

figure();
plot(sum(subj_exes,1), squeeze(mean(cluster_mu_erds(2,:,:),2)),'o');
xlabel('Number executions');
ylabel('C4 mu ERD');
[rho,p]=corr(sum(subj_exes,1)',squeeze(mean(cluster_mu_erds(2,:,:),2)),'type','Spearman');
disp(sprintf('C4: rho=%.3f, p=%.3f', rho, p));

figure();
plot(sum(subj_exes,1), squeeze(mean(mean(cluster_mu_erds(:,:,:),1),2)),'o');
xlabel('Number executions');
ylabel('C mu ERD');
[rho,p]=corr(sum(subj_exes,1)',squeeze(mean(mean(cluster_mu_erds(2,:,:),1),2)),'type','Spearman');
disp(sprintf('C: rho=%.3f, p=%.3f', rho, p));


