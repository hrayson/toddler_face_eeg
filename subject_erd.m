% subj_id = subject to analyze
% conditiion = condition to analyze (relative to baseline)
% mu_range = frequency range of mu rhythm
% baseline = baseline time period
% time_window = time window to look at ERD over
function subject_erd(subj_id, condition, mu_range, baseline, time_window, output_dir, subj_dir)

if nargin<7
    sub_dir=['/data/infant_face_eeg/preprocessed/' num2str(subj_id) '/'];
end
if ~isequal(exist(output_dir, 'dir'),7)
    mkdir(output_dir);
end

clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};
clusters(3).name='O1';
clusters(3).channels={'E69', 'E70', 'E73', 'E74'};
clusters(4).name='O2';
clusters(4).channels={'E83', 'E82', 'E89', 'E88'};

data=pop_loadset([subj_dir num2str(subj_id) '.' condition '.set']);

for i=1:length(clusters)
    [x times freqs]=std_ersp(data,'type','ersp','trialindices',[1:data.trials],'freqs', mu_range, 'nfreqs',10,'freqscale','linear','channels',clusters(i).channels,'baseline',baseline,'savefile','off');
    clusters(i).times=times;
    erd=(10.^(mean(x)/10)-1)*100;
    time_idx=intersect(find(times>=time_window(1)),find(times<=time_window(2)));        
    mean_erd=mean(erd(time_idx));
    clusters(i).mu_erd=erd;
    clusters(i).mu_mean_erd=mean_erd;
end

f=figure();
for i=1:length(clusters)
    subplot(length(clusters)/2,2,i);
    idx=find(clusters(i).times>baseline(2));
    plot(clusters(i).times(idx),clusters(i).mu_erd(idx),'b');
    xlim([baseline(2), clusters(i).times(end)]);
    xlabel('Time (ms)');
    ylabel(['Power - ' num2str(mu_range(1)) '-' num2str(mu_range(2)) 'Hz']);
    title(clusters(i).name);
end
saveas(f,[output_dir 'mu_erd'],'png');

f=figure();
cluster_means=[clusters(1).mu_mean_erd clusters(2).mu_mean_erd; clusters(3).mu_mean_erd clusters(4).mu_mean_erd];
bar(cluster_means);
set(gca,'XTickLabel',{'central','occipital'})
legend('left','right');
title(condition);
saveas(f,[output_dir 'mu_mean_erd'],'png');
