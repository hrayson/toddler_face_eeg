function [times erd mean_erd]=cluster_erd(data, channels, mu_range, freq_range, baseline, time_window, trials)
if nargin<7
    trials=[1:data.trials];
end

[x times freqs]=std_ersp(data,'type','ersp','trialindices',trials,'freqs', freq_range, 'nfreqs', freq_range(2)-freq_range(1)+1, 'freqscale', 'linear', 'cycles', 0, 'padratio', 16, 'channels', channels, 'baseline', NaN, 'savefile', 'off');
mu_idx=intersect(find(round(freqs)>=mu_range(1)),find(round(freqs)<=mu_range(2)));
baseline_idx=intersect(find(times>=baseline(1)),find(times<=baseline(2)));
if length(mu_idx)>1
    sum_band=sum(10.^(x(mu_idx,:)./10));
else
    sum_band=10.^(x(mu_idx,:)./10);
end
R=sum_band(baseline_idx);
time_idx=intersect(find(times>=time_window(1)),find(times<=time_window(2)));        
A=sum_band;
erd=(A-mean(R))./mean(R)*100;
mean_erd=mean(erd(time_idx));

%[x times freqs]=std_ersp(data, 'type', 'ersp', 'trialindices', [1:data.trials], 'freqs', mu_range, 'nfreqs', 10, 'freqscale', 'linear', 'channels', channels, 'baseline', baseline, 'savefile', 'off');
%erd=(10.^(mean(x)/10)-1)*100;
%time_idx=intersect(find(times>=time_window(1)),find(times<=time_window(2)));        
%mean_erd=mean(erd(time_idx));
