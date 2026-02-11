classdef AutoValidationCls
% AutoValidationCls('logSignalstestPatternSimple2.xlsx.txt', 1);
% AutoValidationCls('logSignalstestPatternSimple2TC2.xlsx.txt', 1);
% 第二引数形式
% net_val
% net_val2
% Result_XXXXXX_yyyymmddHHMMSS.xlsx形式
% シートSummary
% B8 検証結果
% C9 検証環境
% C10 実施日時
% C12 OK:一致、NG：不一致
    properties
        modelName
        signalList
        config
        SKIPFLAG=1e-6
    end
    
    methods
        function obj = AutoValidationCls(filename, mode)
            clc;
            % コンストラクタの実行時に引数を使って設定する
            obj.modelName = bdroot();
            obj.signalList = obj.readSignalNames(filename);
            % keys(obj.signalList)
            [err, msg] = obj.chkPreReq();
            if err
                msgbox(msg);
                return;
            end

            [err, msg, obj.config] = obj.initConfig(mode);
            if err
                msgbox(msg);
                return;
            end

            % シミュレーション実施
            obj.config.logSignals = obj.signalList;
            [err, msg, obj.config] = obj.exeSimulation(obj.config);
            if err
                msgbox(msg);
                return;
            end

            [err, msg] = obj.outResult(obj.config);
            if err
                msgbox(msg);
                return;
            end
            disp('finished.');
        end

        %% 
        function signalList = readSignalNames(~, filename)
            signalList = containers.Map('KeyType','char','ValueType','any');
            fid = fopen(filename);
            tline = fgetl(fid);
            while ischar(tline)
                parts = strsplit(strtrim(tline), ',');
                scenario = strtrim(parts{1});
                signals  = strtrim(parts(2:end));
                signalList(scenario) = signals;
                tline = fgetl(fid);
            end
            fclose(fid);
        end
        
        %% 
        function [err, msg] = chkPreReq(obj)
            % 前提条件をチェックする処理
            err = 0;
            msg = '';
            try
                if strcmp(bdroot, 'simulink') || strcmp(bdroot, '')
                    err = 1;
                    msg = {'検証対象のモデルファイルが見当たりません。'; 'モデルが開いた状態でツールを実行。'};
                    return;
                end
                try
                    set_param(bdroot, 'SimulationCommand', 'Update');
                catch
                    err = 1;
                    msg = {'シミュレーション実行不可。'};
                end
            catch
                err = 1;
                msg = {'ツール前確認処理で異常発生。'};
            end
        end

        %% 
function [err, msg, ret] = initConfig(~, okng_mode)
            err = 0;
            msg = '';
    
            try
                ret.model.name = bdroot();
                ret.result.tmp = which('Result_XXXXXX_yyyymmddHHMMSS.xlsx');
                ret.result.file = [pwd '/Result_', ret.model.name, '_', datestr(now, 'yyyymmddHHMMSS'), '.xlsx'];
                ret.result.date = datestr(now, 'yyyy/mm/dd HH:MM:SS');
                ret.result.rawdats = {};
                % 信号データ合否判定用
                ret.result.editdata = {};
                ret.result.judgement = {};
                ret.message.warning{1} = 'MATLAB:xlswrite:AddSheet';
                ret.message.warning{2} = 'Simulink:SampleTime:SourceInheritedTS';
                for i = 1:length(ret.message.warning)
                    warning('off', ret.message.warning{1});
                end
        
                ret.okng_mode=okng_mode;
                    ret.mode = 'SE';
                    ret.signalEditor.handle = find_system(ret.model.name, 'FindAll', 'on', 'BlockType', 'SubSystem', 'MaskType', 'SignalEditor');
            % 取得できるパラメータ名を表示
% params = get_param(gcb, 'ObjectParameters')
                    ret.signalEditor.file = get_param(ret.signalEditor.handle, 'FileName');  % MATファイルパス

% アクティブなシナリオ名を取得
                    ret.signalEditor.activeScenario = get_param(ret.signalEditor.handle, 'ActiveScenario');

% MAT ファイル内のデータをロード
                    data = load(ret.signalEditor.file);

% シナリオ一覧を取得（データ構造のトップレベルの変数がシナリオ名になる）
                    scenarioNames = fieldnames(data);
                    numScenarios = numel(scenarioNames);
                    ret.signalEditor.numScenarios = numScenarios;

% Signal Editor のワークスペース変数を取得
% 結果を保存する構造体
                    ret.signalEditor.scenarioDetails = struct();

                    for i = 1:numScenarios
                        scenarioName = scenarioNames{i};
                        activeScenario=scenarioName;
    % 各シナリオの変数数を取得
                        numVariables = data.(scenarioName).numElements;
    
    % 各変数の StopTime を格納する配列
                        stopTimes = zeros(1, numVariables);
    
                        for j = 1:numVariables
                             variableName = data.(scenarioName){j}.Name;
        
        % 変数が timeseries データであることを確認
                             stopTimes(j) = data.(scenarioName){j}.Time(end);
                        end
    
    % シナリオの情報を構造体に保存
                        ret.signalEditor.scenarioDetails(i).activeScenario = activeScenario;
                        ret.signalEditor.scenarioDetails(i).scenarioName = scenarioName;
                        ret.signalEditor.scenarioDetails(i).numVariables = numVariables;
                        ret.signalEditor.scenarioDetails(i).stopTimes = stopTimes;
                    end
                catch e
                    err = 1;
                    if isempty(e.stack)
                        msg = {'初期設定処理で異常発生。', e.message};
                    else
                        msg = {'初期設定処理で異常発生。';
                         [e.stack(1).name, ' (line: ', num2str(e.stack(1).line), ')']};
                    end
                end
            end

%% 
function datasetSignals = getSDILogData(~, targetSignals)
    % SDIのログデータを取得
    runIDs = Simulink.sdi.getAllRunIDs;
    latestRunID = runIDs(end); % 最新のシミュレーションランを取得
    runData = Simulink.sdi.getRun(latestRunID);

    % Dataset を作成
    datasetSignals = Simulink.SimulationData.Dataset; % 空のDataset作成
    signalCount = runData.SignalCount;

    for l = 1:signalCount
        sig = runData.getSignalByIndex(l);

        % 指定した信号 "net_val" と "ex_net_val" を検索
        % targetSignals は string 配列または cell 配列であると仮定
        % ネストされた cell から中身を取り出す
        if iscell(targetSignals) && iscell(targetSignals{1})
            targetSignals = targetSignals{1};  % 中の cell を取り出す
        end
        % 安全に string 配列へ変換
        if iscell(targetSignals)
            targetSignals = string(targetSignals);
        end
        targetNames = [targetSignals, "ex_" + targetSignals, "<" + targetSignals + ">"];
        if any(ismember(sig.Name, targetNames))
            values = sig.Values;

            if isempty(values) || isempty(values.Time) || isempty(values.Data)
                continue; % データが空ならスキップ
            end

            % Dataset に信号を追加
            ts = timeseries(values.Data, values.Time);
            ts.Name = sig.Name;
            datasetSignals = datasetSignals.addElement(ts);
        end
    end
end

%%
function [err, msg, ret] = exeSimulation(obj, arg_config)
    err = 0;
    msg = '';
    ret = arg_config;
    % try
        tim_tit = {'Time'; ''};
        sig_tit2 = {'', '', ''; 'mdl', 'src', 'OKNG'};
        sig_tit = {'', '';'mdl', 'src'};
        col_mdl = 1;
        col_src = 2;

        allScenarios = {arg_config.signalEditor.scenarioDetails.scenarioName};
        targetScenarios = keys(obj.signalList);  % Mapのキー

        % 実行対象だけ抽出
        validIdx = find(ismember(allScenarios, targetScenarios));
        % numTests を arg_config に格納して渡す。
        ret.validIdx = validIdx;

        for k = 1:length(validIdx)% numTests
            i = validIdx(k);   % ← 実際のscenario index
            clear mex;
            TCName = '';
            simout = [];
             % --- ① シミュレーション実行と保存 ---
            try
                [simout, TCName] = obj.runSingleSimulation(i, arg_config);
                disp(TCName);
                save([TCName, '.mat'], 'simout', '-v7.3');
            catch e
                err = 1;
                msg = {'シミュレーション実施で異常発生';
                [e.stack(1).name, ' (line: ', num2str(e.stack(1).line), ')']};
            end

            % --- ② SDIログ取得・評価処理 ---
            try
                scenarioName = arg_config.signalEditor.scenarioDetails(i).scenarioName;
                if isKey(obj.signalList, scenarioName)
                    targetSignals = obj.signalList(scenarioName);
                else
                    continue  % txtに無いシナリオはスキップ
                end
                [tmp_sigdata, tmp_rawdata, tmp_editdata, tmp_judgement] = ...
                obj.evaluateSimulationOutput(simout, {targetSignals}, arg_config.okng_mode);        
                ret.result.sigName{k} = tmp_sigdata;
                ret.result.rawdata{k} = tmp_rawdata;
                ret.result.editdata{k} = tmp_editdata;
                if any(strcmp(tmp_judgement,'NG'))
                    ret.result.judgement{k,1} = 'NG';
                else
                    ret.result.judgement{k,1} = 'OK';
                end
            catch e
                err = 1;
                msg = {'評価処理失敗';
                [e.stack(1).name, ' (line: ', num2str(e.stack(1).line), ')']};
            end
        end
end

%% 
function [simout, TCName] = runSingleSimulation(obj, i, arg_config)
    TCName = 'untitled';
    
    if strcmp(arg_config.mode, 'SB')
        signalbuilder(arg_config.signalBuilder.handle, 'activegroup', i);
        activeGroup = signalbuilder(arg_config.signalBuilder.handle, 'activegroup');
        [~, ~, ~, groupNames] = signalbuilder(arg_config.signalBuilder.handle);
        TCName = groupNames{activeGroup};
        set_param(arg_config.model.name, 'StopTime', num2str(arg_config.signalBuilder.time{1, i}(end)));
        
    elseif strcmp(arg_config.mode, 'SE')
        TCName = arg_config.signalEditor.scenarioDetails(i).scenarioName;
        assignin('base', arg_config.signalEditor.activeScenario, TCName);
        set_param(arg_config.signalEditor.handle, 'ActiveScenario', TCName);
        stopTimes = arg_config.signalEditor.scenarioDetails(i).stopTimes(2);
        set_param(arg_config.model.name, 'StopTime', num2str(stopTimes));
    end
    
    simout = sim(arg_config.model.name, getActiveConfigSet(arg_config.model.name));
    save([TCName, '.mat'], 'simout', '-v7.3');
end

%% 
function [tmp_sigdata, tmp_rawdata, tmp_editdata, tmp_judgement] = ...
    evaluateSimulationOutput(obj, simout, targetSignals, mode)
    col_mdl = 1;
    col_src = 2;
    tim_tit = {'Time'; ''};
    sig_tit2 = {'', '', ''; 'mdl', 'src', 'OKNG'};
    sig_tit = {'', ''; 'mdl', 'src'};
    
    datasetSignals = obj.getSDILogData(targetSignals);
    numSignals = datasetSignals.numElements;
    
    flg = 1;
    signalLists = targetSignals{1};
    for j = 1:length(signalLists)
        for jj = 1:numel(simout.logsout.getElementNames)
            name_j = simout.logsout{jj}.Name;
            if strcmp(name_j, signalLists{j})
            % 一致した signalList{i} に対して処理を行う
            % element.Data を使った処理を書く
                simout.logsout{jj}.Name;
                signal_data = simout.logsout{jj}.Values.Data;
                % 必要なら break; して外側に戻る
                continue;
                
            elseif strcmp(name_j, [signalLists{j} '_ideal'])
                simout.logsout{jj}.Name;
                signal_ex_data =  simout.logsout{jj}.Values.Data;
                continue;
            else    
            end
        end
          

        if flg
            flg = 0;
            timeVec = simout.logsout{jj}.Values.Time;  % ← jjに合わせる
            timeCol = num2cell(timeVec);
            tmp_editdata = [{'Time'; ''}; timeCol];
            tmp_rawdata  = [{'Time'; ''}; timeCol];
            tmp_sigdata = {};
        end

        sig_val_raw = num2cell([signal_data, signal_ex_data]);
        sig_val_edit = [obj.editData(sig_val_raw(:,1)), obj.editData(sig_val_raw(:,2))];

        sig_tit2{1, 1} = signalLists{j};

        tmp_rawdata = [tmp_rawdata, [sig_tit; sig_val_raw]];
        tmp_sigdata = [tmp_sigdata, signalLists{j}];

        % 判定処理
        tolerance = obj.SKIPFLAG;
        is_equal = all(abs(cell2mat(sig_val_raw(:, col_mdl)) - ...
                           cell2mat(sig_val_raw(:, col_src))) < tolerance);
 
        % === 判定処理（mode による切り替え） ===
        numRows = size(sig_val_raw, 1); % データの行数
        sig_results = cell(numRows, 1); % 判定結果を格納する cell 配列
        % 判定モード（第3引数で切り替え）
        if nargin < 3 || isempty(mode)
            mode = 0;  % デフォルト：完全一致チェック
        end

        for row = 1:numRows
    val_mdl = sig_val_raw{row, col_mdl};
    val_src = sig_val_raw{row, col_src};

    if mode == 1
        % src列がｽｷｯﾌﾟﾌﾗｸﾞSKIPFLAGの場合は '-' にする
        if isequal(obj.SKIPFLAG, val_src)
            sig_results{row} = '-';
        elseif isequal(val_mdl, val_src)
            sig_results{row} = 'OK';
        else
            sig_results{row} = 'NG';
        end
    else
        % 従来通りの比較（数値の近似一致チェック）
        if isequal(val_mdl, val_src)
            sig_results{row} = 'OK';
        else
            sig_results{row} = 'NG';
        end
    end
        end
        tmp_editdata = [tmp_editdata, [sig_tit2; [sig_val_raw, sig_results]]];

        % src列とmdl列を取得
        src_col = sig_val_raw(:, col_src);
        mdl_col = sig_val_raw(:, col_mdl);

        % 期待値列がすべて '-' の場合
        if all(cellfun(@(x) isequal(x, obj.SKIPFLAG), src_col))
            tmp_judgement{j} = '-';
        % モデル出力と期待値が不一致のものが1つでもある場合（'-' は無視）
        elseif any(~cellfun(@(s, m) isequal(s, obj.SKIPFLAG) || isequal(s, m), src_col, mdl_col))
            tmp_judgement{j} = 'NG';
        % 上記以外 → 有効な比較すべてが一致していた
            else
            tmp_judgement{j} = 'OK';
        end  
    end
end

%% 
function ret = editData(~, arg_sig_val)
    cnt = 1;
    base = 1;
    ret = cell(size(arg_sig_val));
    ret{cnt} = arg_sig_val{base};
    for row_pos = 2:length(arg_sig_val)
        if(arg_sig_val{base} == arg_sig_val{row_pos} )
            cnt = cnt +1;
            ret{cnt} = arg_sig_val{row_pos};
            base = row_pos;
        end
    end
end

%% 
function [err, msg] = outResult(obj, arg_config)
    err = 0;
    msg = '';
    % EXCELサーバ作成
    ex = actxserver('Excel.Application');
    wb = ex.workbooks.Open(arg_config.result.tmp);
    ex.Visible = 1;
    try
        obj.outSummary(wb, arg_config);
        for i = 1:length(arg_config.validIdx)
            idx = arg_config.validIdx(i);
            % disp(arg_config.result.editdata)
            obj.outSigData(wb, ...
            arg_config.result.editdata{i}, ...
            arg_config.signalEditor.scenarioDetails(idx).scenarioName);
        end
        wb.Sheets(1).Select;
        wb.SaveAs(arg_config.result.file);
    catch e
        err = 1;
        msg = {'シミュレーション実施で異常発生';
        [e.stack(1).name, ' (line: ', num2str(e.stack(1).line), ')']};
    end

    % post process
    wb.Saved = 1;
    Close(wb);
    Quit(ex);
    delete(ex);
end

%% 
function outSummary(~, arg_wb, arg_config)
    sheet_name = 'Summary';
    pos_env_name = 'D9';
    pos_sim_date = 'D10';

    if strcmp(arg_config.mode, 'SB')
        tp_num = length(arg_config.signalBuilder.testpattern);
    elseif strcmp(arg_config.mode, 'SE')
        tp_num = length(arg_config.validIdx);
    else
    end    
    sig_num = length(arg_config.result.sigName{1});

    row_s = 13;
    row_e = row_s + tp_num;
    tp_col = 3;
    sig_col_s = 6;
    sig_col_e = sig_col_s + sig_num - 1;

    % Summary sheet
    sh = arg_wb.Sheets.Item(sheet_name);
    sh.Activate;
    sh.Range(pos_env_name).Value = arg_config.model.name;
    sh.Range(pos_sim_date).Value = arg_config.result.date;
%     テストパターン
    tp_pos_s = get(sh, 'Cells', row_s, tp_col);
    tp_pos_e = get(sh, 'Cells', row_e, tp_col);
    tp_range = get(sh, 'Range', tp_pos_s, tp_pos_e);
    if strcmp(arg_config.mode, 'SB')    
        tp_range.Value = [{'テストパターン'}; arg_config.signalBuilder.testpattern'];
    elseif strcmp(arg_config.mode, 'SE')
        % 事前に 'テストパターン' を含めたセル配列を初期化
        tp_range.Value = [{'テストパターン'}; cell(arg_config.signalEditor.numScenarios, 1)];

        % シナリオ数分ループして scenarioName を追加
        for k = 1:length(arg_config.validIdx)
            idx = arg_config.validIdx(k);
            tp_range.Value{k+1} = arg_config.signalEditor.scenarioDetails(idx).scenarioName;
        end   
    else
    end    
    % 信号データ
    sig_pos_s = get(sh, 'Cells', row_s, sig_col_s);
    sig_pos_e = get(sh, 'Cells', row_e, sig_col_e);
    sig_range = get(sh, 'Range', sig_pos_s, sig_pos_e);
    sig_range.Value = [arg_config.result.sigName{1,1}; arg_config.result.judgement];

    for i=0:tp_num
        tp_merge_s = get(sh, 'Cells', (row_s + 1), tp_col);
        tp_merge_e = get(sh, 'Cells', (row_s + 1), sig_col_e - 1);
        tp_merge = get(sh, 'Range', tp_merge_s, tp_merge_e);
        % tp_merge.Merge;
    end
    tit_pos_s = tp_pos_s;
    tit_pos_e = get(sh, 'Cells', row_s, sig_col_e);
    tit_range = get(sh, 'Range', tit_pos_s, tit_pos_e);
    tit_range.interior.Color = hex2dec('FFFFC8');

    % NG
    ng_range = sig_range.Find('NG');
    if(~isempty(ng_range))
        ng_range_1 = ng_range.Address;
        ng_range_next = '';
        while(~strcmp(ng_range_1, ng_range_next))
            ng_range.Interior.Color = hex2dec('0000FF');
            ng_range = sig_range.FindNext(ng_range);
            ng_range_next = ng_range.Address;
        end
    end
    % OK
    ok_range = sig_range.Find('OK');
    if(~isempty(ok_range))
        ok_range_1 = ok_range.Address;
        ok_range_next = '';
        while(~strcmp(ok_range_1, ok_range_next))
            ok_range.Interior.Color = hex2dec('80FFFF');
            ok_range = sig_range.FindNext(ok_range);
            ok_range_next = ok_range.Address;
        end
    end
end

%% 
function outSigData(~, arg_wb, arg_data, arg_testpattern)
    sh = arg_wb.Sheets;
    sh_end = sh.Item(sh.Count);
    sh_new = sh.Add([], sh_end);
    sh_new.Activate;

    pos_row = size(arg_data, 1);
    pos_col = size(arg_data, 2);
    pos_s = get(sh_new, 'Cells', 1, 1);
    pos_e = get(sh_new, 'Cells', pos_row, pos_col);
    rng = get(sh_new, 'Range', pos_s, pos_e);

% --- Time列を必ず左端に追加 ---
% if ~strcmp(arg_data{1,1}, 'Time')
%     time_col = arg_data(:,1);      % Time列（evaluateSimulationOutputで生成済み）
%     arg_data = [time_col, arg_data(:,2:end)];
% end

    rng.Value = arg_data;

    offset = 0;
    if(strcmp(sh_new.Range('A1').Value, 'Time'))
        sh_new.Range('A1:A2').Merge;
        offset = 1;
    end
    for i=1:size(arg_data, 2) - offset
        sig_col = i * 2;
        if((sig_col <= size(arg_data, 2)) && ~isempty(arg_data{1, sig_col + offset - 1}))
            sig_pos_s = get(sh_new, 'Cells', 1, sig_col + offset - 1);
            sig_pos_e = get(sh_new, 'Cells', 1, sig_col + offset);
            sig_range = get(sh_new, 'Range', sig_pos_s, sig_pos_e);
            sig_range.Merge;
        end
    end
    rng_b = sh_new.Range('A1').CurrentRegion;
    rng_b.Borders.LineStyle = 1;

    if(offset)
        sh_new.Name = arg_testpattern;
    else
        sh_new.Name = [arg_testpattern, '#'];
    end
end
    end
end
