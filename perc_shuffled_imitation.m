function [perc,num_shuffled_movements]=perc_shuffled_imitation(subj_id)

max_latency=2;
data=pop_loadset(['/data/infant_face_eeg/raw/' num2str(subj_id) '/' num2str(subj_id) '.events.set']);
behavior_fid=fopen(['/data/infant_face_eeg/raw/' num2str(subj_id) '/' num2str(subj_id) 'JH.csv']);
lines=textscan(behavior_fid,'%s','Delimiter','\n','CollectOutput',true);
for i=3:length(lines{1})
    cols=strsplit(lines{1}{i},',');
    movement=cols{2};

    init_onset=cols{3};
    init_onset_min=str2num(init_onset(1:2));
    init_onset_sec=str2num(init_onset(4:5));
    init_onset_ms=str2num(init_onset(7:end));
    init_onset_level=str2num(cols{4});

    init_offset=cols{5};
    init_offset_min=str2num(init_offset(1:2));
    init_offset_sec=str2num(init_offset(4:5));
    init_offset_ms=str2num(init_offset(7:end));    
    init_offset_level=str2num(cols{6});

    init_latency=init_onset_min*60.0+init_onset_sec+0.001*init_onset_ms;
    init_duration=(init_offset_min*60.0+init_offset_sec+0.001*init_offset_ms)-init_latency;
    init_magnitude=init_offset_level-init_onset_level;
    data = pop_editeventvals(data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' init_latency},'changefield',{2 'duration' init_duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' init_magnitude},'changefield',{2 'movement' movement});
end

last_mov_start=-1;
last_mov_end=-1;
code='';
mvmt='';

num_shuffled_movements=0.0;
num_shuffled_imitations=0.0;

for i=1:length(data.event)
    if strcmp(data.event(i).type,'mov1')
        last_mov_start=data.event(i).latency;
        code=data.event(i).code;
        mvmt=data.event(i).movement;
    elseif strcmp(data.event(i).type,'mov2')
        last_mov_end=data.event(i).latency;
    elseif strcmp(data.event(i).type,'artifact') && strcmp(data.event(i).code,'noat')==0
        if (last_mov_start>-1 && last_mov_end<0) || (last_mov_start>-1 && last_mov_end>-1 && last_mov_start<=data.event(i).latency<=last_mov_end+max_latency*data.srate)
            if strcmp(code,'shuf')
                num_shuffled_movements=num_shuffled_movements+1.0;
                if (strcmp(mvmt,'mopn') && strcmp(data.event(i).movement,'MO')) || (strcmp(mvmt,'frwn') && strcmp(data.event(i).movement,'S')) || (strcmp(mvmt,'smil') && strcmp(data.event(i).movement,'J'))
                    num_shuffled_imitations=num_shuffled_imitations+1.0;
                end
            end
        end
    end
end
perc=num_shuffled_imitations/num_shuffled_movements*100.0;
