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
            % ===== 複数TC → 分割 =====
            for i = 1:numel(fn)
                tcName = fn{i};
                TEST = data.(tcName);

                if isempty(TEST)
                    continue;
                end

                % ===== SimulationOutput対応 =====
                if isa(TEST, 'Simulink.SimulationOutput')
                    if isprop(TEST, 'logsout')
                        TEST = TEST.logsout;
                    end
                end

                % ===== Dataset内 _ideal 除去 =====
                if isa(TEST, 'Simulink.SimulationData.Dataset')
                    newDs = Simulink.SimulationData.Dataset;

                    for j = 1:TEST.numElements
                        elem = TEST.getElement(j);
% ---- 名前取得（強化版）----
if ~isempty(elem.Name)
    sigName = elem.Name;
elseif ~isempty(elem.BlockPath)
    sigName = char(elem.BlockPath);
else
    sigName = '';
end

sigName = strtrim(sigName);

% パスの最後だけ取る
parts = split(sigName, '/');
sigName = parts{end};

if isempty(sigName) || endsWith(sigName, '_ideal')
    continue;
end
newDs = newDs.addElement(elem);
                    end

                    TEST = newDs;
                end

                runName = sprintf('%s_%s', baseRunName, tcName);
                Simulink.sdi.createRun(runName, 'vars', TEST);
            end

        else
            % ===== 単一 → 従来通り =====
            TEST = data.(fn{1});

            if isa(TEST, 'Simulink.SimulationOutput')
                if isprop(TEST, 'logsout')
                    TEST = TEST.logsout;
                end
            end

            Simulink.sdi.createRun(baseRunName, 'vars', TEST);
        end

    catch ME
        warning('Failed: %s (%s)', files(k).name, ME.message);
    end
end

end