function importMatToSDI2(folderPath)
clc;
if nargin == 0
    folderPath = pwd;
end

Simulink.sdi.clear;
files = dir(fullfile(folderPath, '*.mat'));

for k = 1:numel(files)
    filePath = fullfile(folderPath, files(k).name);
    files(k).name

    try
        data = load(filePath);
        fn = fieldnames(data);

        [~, baseRunName, ~] = fileparts(files(k).name);

if numel(fn) > 1
    for i = 1:numel(fn)
        tcName = fn{i};
        TEST = data.(tcName);

        % % if isstruct(TEST)
        %     f = fieldnames(TEST);
        % 
        %     % _idealだけ残す
        %     idx = contains(f, '_ideal');
        %     TEST = rmfield(TEST, f(~idx));
        % 
        %     % ideal削除（_は残る）
        %     f = fieldnames(TEST);
        %     for k2 = 1:numel(f)
        %         newName = erase(f{k2}, 'ideal');
        %         if ~strcmp(f{k2}, newName)
        %             TEST.(newName) = TEST.(f{k2});
        %             TEST = rmfield(TEST, f{k2});
        %         end
        %     end
        % % end

        runName = sprintf('%s_%s', baseRunName, tcName);
        Simulink.sdi.createRun(runName, 'vars', TEST);
    end
else
    % 単一TC
    TEST = data.(fn{1});
        % _ideal フィールド削除（struct用）
    if isstruct(TEST)
        f = fieldnames(TEST);
        TEST = rmfield(TEST, f(contains(f, '_ideal')));
    end

    Simulink.sdi.createRun(baseRunName, 'vars', TEST);    
end    

    catch ME
        warning('Failed: %s (%s)', files(k).name, ME.message);
    end
end

end

function ds = filterDataset(TEST, mode)
    ds = Simulink.SimulationData.Dataset;

    for j = 1:TEST.numElements
        elem = TEST.getElement(j);

        % ---- 名前取得 ----
        if ~isempty(elem.Name)
            sigName = elem.Name;
        elseif ~isempty(elem.BlockPath)
            sigName = char(elem.BlockPath);
            parts = split(sigName, '/');
            sigName = parts{end};
        else
            sigName = '';
        end

        sigName = strtrim(sigName);

        isIdeal = endsWith(sigName, '_ideal');

        if strcmp(mode, 'removeIdeal')
            % ===== 単一TC：_ideal削除 =====
            if isIdeal
                continue;
            end

        elseif strcmp(mode, 'onlyIdeal')
            % ===== 複数TC：_idealだけ抽出 =====
            if ~isIdeal
                continue;
            end

            % "ideal"だけ削除（_は残す）
            sigName = erase(sigName, 'ideal');  % gfgo4_ideal → gfgo4_
            elem.Name = sigName;
        end

        ds = ds.addElement(elem);
    end
end