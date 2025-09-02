function [included_subjects excluded_subjects]=exclude_subjects(subj_ids, conditions, subj_dir_ext, file_ext)

excluded_subjects=[];
for k=1:length(conditions)
    for j=1:length(subj_ids)
        subj_id=subj_ids(j);
        if length(find(excluded_subjects==subj_id))==0
            if exist(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.' conditions{k} file_ext '.set'],'file')
                data=pop_loadset(['/data/infant_face_eeg/preprocessed/' num2str(subj_id) subj_dir_ext '/' num2str(subj_id) '.' conditions{k} file_ext '.set']);
                if data.trials<5
                    excluded_subjects(end+1)=subj_id;
                end
            else
                excluded_subjects(end+1)=subj_id;
            end
        end
    end
end
included_subjects=setdiff(subj_ids,excluded_subjects);        

