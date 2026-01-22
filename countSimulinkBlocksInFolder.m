function countSimulinkBlocksInFolderRecursive()
% フォルダ選択 → 配下すべてのサブフォルダを再帰的に探索し
% Simulinkモデルごとにブロック数を表示

    targetDir = uigetdir(pwd, 'Simulinkモデルのあるフォルダを選択');
    if targetDir == 0
        disp('キャンセルされました。');
        return;
    end

    % 再帰的に .slx / .mdl を収集
    files = [ ...
        dir(fullfile(targetDir,'**','*.slx')); ...
        dir(fullfile(targetDir,'**','*.mdl'))  ...
    ];

    if isempty(files)
        disp('指定フォルダ配下に Simulink モデルが見つかりません。');
        return;
    end

    fprintf('Target Folder (recursive): %s\n\n', targetDir);

    for k = 1:numel(files)
        modelFile = fullfile(files(k).folder, files(k).name);
        [~, modelName, ~] = fileparts(modelFile);

        try
            load_system(modelFile);

            blocks = find_system(modelName, ...
                'LookUnderMasks','all', ...
                'FollowLinks','on', ...
                'Type','Block');

            fprintf('Model: %-30s  Blocks: %d\n', ...
                modelName, numel(blocks));

            close_system(modelName, 0);

        catch ME
            fprintf('Model: %-30s  ERROR: %s\n', ...
                modelName, ME.message);
            bdclose(modelName);
        end
    end
end
