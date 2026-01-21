function countSimulinkBlocksInFolder()
% フォルダ選択 → 配下の Simulink モデルごとにブロック数を表示

    targetDir = uigetdir(pwd, 'Simulinkモデルのあるフォルダを選択');
    if targetDir == 0
        disp('キャンセルされました。');
        return;
    end

    files = [ ...
        dir(fullfile(targetDir,'*.slx')); ...
        dir(fullfile(targetDir,'*.mdl'))  ...
    ];

    if isempty(files)
        disp('指定フォルダに Simulink モデルが見つかりません。');
        return;
    end

    fprintf('Target Folder: %s\n\n', targetDir);

    for k = 1:numel(files)
        modelFile = fullfile(files(k).folder, files(k).name);
        [~, modelName, ~] = fileparts(modelFile);

        try
            load_system(modelFile);

            blocks = find_system(modelName, ...
                'LookUnderMasks','all', ...   % ← 必ず最初
                'FollowLinks','on', ...       % ← 必ず最初
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
