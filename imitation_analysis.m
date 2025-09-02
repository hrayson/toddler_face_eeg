function imitation_analysis(file_ext)

mu_data_fid=fopen(['/data/infant_face_eeg/analysis/subject_6-9Hz_erd' file_ext '.csv']);
%imitation_mu_data_fid=fopen(['/data/infant_face_eeg/analysis/subject_6-9Hz_erd_imitation' file_ext '.csv'],'w');

lines=textscan(mu_data_fid,'%s','Delimiter','\n','CollectOutput',true);

unshuffled_imitation_freqs=[];
emotion_imitation_freqs=[];
mouthopen_imitation_freqs=[];
happy_imitation_freqs=[];
sad_imitation_freqs=[];
shuffled_imitation_freqs=[];

unshuffled_movement_freqs=[];
emotion_movement_freqs=[];
mouthopen_movement_freqs=[];
happy_movement_freqs=[];
sad_movement_freqs=[];
shuffled_movement_freqs=[];

unshuffled_imitation_movement_freqs=[];
emotion_imitation_movement_freqs=[];
mouthopen_imitation_movement_freqs=[];
happy_imitation_movement_freqs=[];
sad_imitation_movement_freqs=[];
shuffled_imitation_movement_freqs=[];

subj_ids=[];

title_cols=strsplit(lines{1}{1},', ');
%fprintf(imitation_mu_data_fid, [lines{1}{1} ', ShuffledImitationFreq, UnshuffledImitationFreq, EmotionImitationFreq, MouthOpenImitationFreq, HappyImitationFreq, SadImitationFreq\n']);

for i=2:length(lines{1})
    cols=strsplit(lines{1}{i},', ');   
 
    for j=1:length(title_cols)
        if strcmp(title_cols(j),'Subject')
            subj_id=cols(j);
            subj_ids(end+1)=subj_id;
        end
    end
    %[unshuffled_imitation_freqs(end+1) emotion_imitation_freqs(end+1) mouthopen_imitation_freqs(end+1) happy_imitation_freqs(end+1) sad_imitation_freqs(end+1) shuffled_imitation_freqs(end+1) shuffled_imitations(end+1) happy_movements(end+1) mouthopen_movements(end+1) sad_movements(end+1)]=analyze_movement_events(subj_id, [num2str(subj_id) 'JH.csv'], 2);
    [shuffled_movements mouthopen_movements happy_movements sad_movements shuffled_imitations mouthopen_imitations happy_imitations sad_imitations shuffled_trials mouthopen_trials happy_trials sad_trials]=analyze_movement_events(subj_id, [num2str(subj_id) 'JH.csv'], 0);

    unshuffled_imitation_freqs(end+1)=(length(mouthopen_imitations)+length(happy_imitations)+length(sad_imitations))/(mouthopen_trials+happy_trials+sad_trials)*100.0;
    emotion_imitation_freqs(end+1)=(length(happy_imitations)+length(sad_imitations))/(happy_trials+sad_trials)*100.0;
    mouthopen_imitation_freqs(end+1)=length(mouthopen_imitations)/mouthopen_trials*100.0;
    happy_imitation_freqs(end+1)=length(happy_imitations)/happy_trials*100.0;
    sad_imitation_freqs(end+1)=length(sad_imitations)/sad_trials*100.0;
    shuffled_imitation_freqs(end+1)=length(shuffled_imitations)/shuffled_trials*100.0;

    unshuffled_movement_freqs(end+1)=(length(mouthopen_movements)+length(happy_movements)+length(sad_movements))/(mouthopen_trials+happy_trials+sad_trials)*100.0;
    emotion_movement_freqs(end+1)=(length(happy_movements)+length(sad_movements))/(happy_trials+sad_trials)*100.0;
    mouthopen_movement_freqs(end+1)=length(mouthopen_movements)/mouthopen_trials*100.0;
    happy_movement_freqs(end+1)=length(happy_movements)/happy_trials*100.0;
    sad_movement_freqs(end+1)=length(sad_movements)/sad_trials*100.0;
    shuffled_movement_freqs(end+1)=length(shuffled_movements)/shuffled_trials*100.0;

    if length(mouthopen_movements)+length(happy_movements)+length(sad_movements)>0
        unshuffled_imitation_movement_freqs(end+1)=(length(mouthopen_imitations)+length(happy_imitations)+length(sad_imitations))/(length(mouthopen_movements)+length(happy_movements)+length(sad_movements))*100.0;
    end
    if length(happy_movements)+length(sad_movements)>0
        emotion_imitation_movement_freqs(end+1)=(length(happy_imitations)+length(sad_imitations))/(length(happy_movements)+length(sad_movements))*100.0;
    end
    if length(mouthopen_movements)>0
        mouthopen_imitation_movement_freqs(end+1)=length(mouthopen_imitations)/length(mouthopen_movements)*100.0;
    end
    if length(happy_movements)>0
        happy_imitation_movement_freqs(end+1)=length(happy_imitations)/length(happy_movements)*100.0;
    end
    if length(sad_movements)>0
        sad_imitation_movement_freqs(end+1)=length(sad_imitations)/length(sad_movements)*100.0;
    end
    if length(shuffled_movements)>0
        shuffled_imitation_movement_freqs(end+1)=length(shuffled_imitations)/length(shuffled_movements)*100.0;
    else
        shuffled_imitation_movement_freqs(end+1)=0;
    end

    %fprintf(imitation_mu_data_fid, [lines{1}{i} ', ' num2str(shuffled_imitation_freqs(end)) ', ' num2str(unshuffled_imitation_freqs(end)) ', ' num2str(emotion_imitation_freqs(end)) ', ' num2str(mouthopen_imitation_freqs(end)) ', ' num2str(happy_imitation_freqs(end)) ', ' num2str(sad_imitation_freqs(end)) '\n']);
end
%fclose(imitation_mu_data_fid);
n_subjects=length(subj_ids);
%subj_ids
%shuffled_imitation_freqs
%shuffled_imitations
%happy_movements
%mouthopen_movements
%sad_movements
%all_movements=happy_movements+mouthopen_movements+sad_movements

figure();
barwitherr([std(shuffled_movement_freqs) std(mouthopen_movement_freqs) std(happy_movement_freqs) std(sad_movement_freqs)]./sqrt(n_subjects), [mean(shuffled_movement_freqs) mean(mouthopen_movement_freqs) mean(happy_movement_freqs) mean(sad_movement_freqs)]);
set(gca,'XTickLabel',{'shuffled','mouth open','happy','sad'});
ylabel('Movement Frequency (% of trials moved during)');
ylim([0 80]);

figure();
barwitherr([std(shuffled_imitation_freqs) std(mouthopen_imitation_freqs) std(happy_imitation_freqs) std(sad_imitation_freqs)]./sqrt(n_subjects), [mean(shuffled_imitation_freqs) mean(mouthopen_imitation_freqs) mean(happy_imitation_freqs) mean(sad_imitation_freqs)]);
set(gca,'XTickLabel',{'shuffled','mouth open','happy','sad'});
ylabel('Imitation Frequency (% of trials imitated)');
ylim([0 80]);

figure();
barwitherr([std(shuffled_imitation_movement_freqs) std(mouthopen_imitation_movement_freqs) std(happy_imitation_movement_freqs) std(sad_imitation_movement_freqs)]./sqrt(n_subjects), [mean(shuffled_imitation_movement_freqs) mean(mouthopen_imitation_movement_freqs) mean(happy_imitation_movement_freqs) mean(sad_imitation_movement_freqs)]);
set(gca,'XTickLabel',{'shuffled','mouth open','happy','sad'});
ylabel('Imitation Frequency (% of movements that were imitation)');
ylim([0 80]);

