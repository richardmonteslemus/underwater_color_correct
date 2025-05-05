function files = remove_non_files(files)

del_ind = [];
for i = 1:numel(files)
    if strcmp(files(i).name(1),'.') || files(i).isdir
        del_ind = [del_ind;i];
    end
end

files(del_ind) = [];