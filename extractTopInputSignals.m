function signalInfo = extractTopInputSignals()
% extractTopInputSignals
%
% GUIでSimulinkモデルを選択し、
% 最上位階層の入力ポート番号と信号名を抽出
%
% 戻り値:
%   signalInfo : table
%
% 出力例:
%   PortNumber    SignalName
%   __________    __________
%        1        VehicleSpeed
%        2        YawRate
%
% 保存:
%   モデルと同じフォルダへ
%   「モデル名_InputSignals.txt」を出力

    %% モデル選択
    [file, path] = uigetfile( ...
        {'*.slx;*.mdl', 'Simulink Model (*.slx, *.mdl)'}, ...
        'モデルを選択してください');

    if isequal(file, 0)
        disp('キャンセルされました');
        signalInfo = table;
        return;
    end

    modelFile = fullfile(path, file);

    %% モデルロード
    load_system(modelFile);

    % モデル名取得
    [~, modelName, ~] = fileparts(file);

    %% 最上位階層のInport取得
    inports = find_system( ...
        modelName, ...
        'SearchDepth', 1, ...
        'BlockType', 'Inport');

    %% Port番号取得
    portNums = zeros(length(inports),1);

    for i = 1:length(inports)
        portNums(i) = str2double( ...
            get_param(inports{i}, 'Port'));
    end

    %% Port番号順ソート
    [portNums, idx] = sort(portNums);
    inports = inports(idx);

    %% 信号名取得
    signalNames = cell(length(inports),1);

    for i = 1:length(inports)

        ph = get_param(inports{i}, 'PortHandles');

        % Inportブロックの出力線
        lineHandle = get_param(ph.Outport, 'Line');

        if lineHandle ~= -1
            sigName = get_param(lineHandle, 'Name');
        else
            sigName = '';
        end

        % 信号名未設定時はInport名
        if isempty(sigName)
            sigName = get_param(inports{i}, 'Name');
        end

        signalNames{i} = sigName;
    end

    %% table化
    signalInfo = table( ...
        portNums, ...
        signalNames, ...
        'VariableNames', {'PortNumber', 'SignalName'});

    %% 表示
    disp(signalInfo);

    %% txt保存
    txtFile = fullfile( ...
        path, ...
        [modelName '_InputSignals.txt']);

    fid = fopen(txtFile, 'w');

    fprintf(fid, 'PortNumber\tSignalName\n');

    for i = 1:height(signalInfo)
        fprintf(fid, '%d\t%s\n', ...
            signalInfo.PortNumber(i), ...
            signalInfo.SignalName{i});
    end

    fclose(fid);

    fprintf('保存完了: %s\n', txtFile);

    %% 必要なら閉じる
    % close_system(modelName, 0);

end