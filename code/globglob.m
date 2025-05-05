files = dir('C:\Users\olena\Desktop\Neta\data\D1\raw\*')

filepaths = [];
for i = 1:numel(files)
    if files(i).name == '.'
    continue
    end
    filepaths = [filepaths, ,fullfile(files(i).folder, files(i).name)];
end

filepaths