
function importMatToSDI(folderPath)
% フォルダ内の.matをSDIへRun名＝ファイル名で登録
% importMatToSDI(pwd);
if nargin == 0
    folderPath = pwd;
end

files = dir(fullfile(folderPath, '*.mat'));

for k = 1:numel(files)
    filePath = fullfile(folderPath, files(k).name);
    data = load(filePath);
    fn = fieldnames(data);

    if isempty(fn)
        warning('Skip (no variable): %s', files(k).name);
        continue;
    end

    % 先頭変数を使用
    runID = Simulink.sdi.createRun( ...
        files(k).name, ...
        'vars', data.(fn{1}) ...
    );
end

end