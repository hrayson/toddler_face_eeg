function all_subjects_tf(subj_ids, freq_range, baseline)

channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54', 'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};
conditions={'happy','sad','movement','shuffled'};

[included_subjects excluded_subjects]=exclude_subjects(subj_ids, conditions, '', '.interp');

tf=[];
for j=1:length(included_subjects)
    subj_id=included_subjects(j);
    data=pop_loadset(fullfile('/data/infant_face_eeg/preprocessed/', num2str(subj_id), [num2str(subj_id) '.rereferenced.interp.set']));
    [nomove,nomove_idx]=pop_selectevent(data, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');
    trials=[1:nomove.trials];
    subj_tf=[];
    for k=1:length(channels)
        [x times freqs]=std_ersp(nomove,'type','ersp','trialindices',trials,'freqs', freq_range, 'nfreqs', 100, 'freqscale', 'linear', 'cycles', 0, 'padratio', 16, 'channels', {channels{k}}, 'baseline', baseline, 'savefile', 'off', 'verbose', 'off');
        subj_tf(k,:,:)=x;
    end
    tf(j,:,:)=squeeze(mean(subj_tf));
end

figure();
imagesc(times-750, freqs, squeeze(mean(tf)));
set(gca,'YDir','normal');
xlabel('Time');
ylabel('Frequency');
