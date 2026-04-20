function importMatToSDI(folderPath)

if nargin == 0
    folderPath = pwd;
end

files = dir(fullfile(folderPath, '*.mat'));

for k = 1:numel(files)
    filePath = fullfile(folderPath, files(k).name);

    try
        data = load(filePath);
        % fn_all = fieldnames(data);
        fn = fieldnames(data);

        % % ========= デバッグ（_ideal変数検出） =========
        % if any(contains(fn_all, '_ideal'))
        %     fprintf('Detected _ideal variable in file: %s\n', files(k).name);
        %     disp(fn_all(contains(fn_all, '_ideal')));
        %     % keyboard; % 必要ならON
        % end
        % 
        % % ========= 外側 "_ideal" 除外 =========
        % fn = fn_all(~endsWith(fn_all, '_ideal'));
        % 
        % if isempty(fn)
        %     warning('Skip (no valid variable): %s', files(k).name);
        %     continue;
        % end
        % 
        % ========= 変数選択 =========
        if ismember('simout', fn)
            TEST = data.simout;
        elseif ismember('logsout', fn)
            TEST = data.logsout;
        else
            TEST = data.(fn{1});
        end

        % ========= 空チェック =========
        if isempty(TEST)
            warning('Skip (empty data): %s', files(k).name);
            continue;
        end

        % ========= SimulationOutput対応 =========
        if isa(TEST, 'Simulink.SimulationOutput')
            if isprop(TEST, 'logsout')
                TEST = TEST.logsout;
            end
        end

        % ========= struct内 "_ideal" 除外 =========
        if isstruct(TEST)
            sigNames = fieldnames(TEST);

            idealIdx = endsWith(sigNames, '_ideal');

            if any(idealIdx)
                fprintf('Removed _ideal signals in file: %s\n', files(k).name);
                disp(sigNames(idealIdx));

                TEST = rmfield(TEST, sigNames(idealIdx));
            end
        end

        % ========= Run名 =========
        [~, runName, ~] = fileparts(files(k).name);

        % ========= SDI登録 =========
        Simulink.sdi.createRun(runName, 'vars', TEST);

    catch ME
        warning('Failed: %s (%s)', files(k).name, ME.message);
    end
end

end