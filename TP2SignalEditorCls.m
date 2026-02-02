classdef TP2SignalEditorCls
% (使用例)
% testPatternSimple.xlsxファイルの左端から3列目（Time列含む）までを入力データとしたい場合
% % TP2SignalEditor クラスをインスタンス化;データを処理
% editor = TP2SignalEditorCls('testPatternSimple.xlsx', '1:3');editor.process();
% editor = TP2SignalEditorCls('testPatternSimple2.xlsx', '1:5');editor.process();
% editor = TP2SignalEditorCls('TV2日本語.xlsx', '1:4');editor.process();
% editor = TP2SignalEditorCls('TV2日本語.xlsx', '1:4', 0.01);editor.process();
    properties
        XlsFile
        SignalRange
        Ts          % [] or scalar
    end
    
    methods
        function obj = TP2SignalEditorCls(xlsfile, SignalRange, Ts)
            obj.XlsFile = xlsfile;
            obj.SignalRange = SignalRange;
            if nargin < 3 || isempty(Ts)
                obj.Ts = [];
            else
                obj.Ts = Ts;
            end
        end
        
        function process(obj)
            column = strsplit(obj.SignalRange, ':');
            raw = [];
            [~, sheets] = xlsfinfo(obj.XlsFile);
            numSheets = length(sheets);

            for iSheet=1:numSheets
                [~,~,iRaw]= xlsread(obj.XlsFile,sheets{iSheet});
                [~, numCols] = size(iRaw);
                activeGroupName = cell(1, numCols);
                activeGroupName{1, str2double(column{1})} = ['<TV>' sheets{iSheet}];
                raw = vertcat(raw, activeGroupName, iRaw);
            end

            inData = raw;
            [~, numCols] = size(inData);

            if str2double(column{2}) < numCols
                for iColumn=1:numCols-str2double(column{2})
                    inData(:, numCols - iColumn + 1) = [];
                end
            end

            if str2double(column{1}) > 1
                for iColumn=0:str2double(column{1})-1
                    inData(:, iColumn) = [];
                end
            end

            keywd = '<TV>';
            sigrawdata = obj.getSignalFromRaw(inData, keywd);
            TestCaseName{numSheets} = '';
            for p=1:length(sigrawdata)
                TestCaseName{p} = sigrawdata(p).name;
                simdata(p).time = sigrawdata(p).numericdata(:,1);
                for n=1:length(sigrawdata(p).labels)
                    simdata(p).signals(n).label = sigrawdata(p).labels{n};
                    simdata(p).signals(n).values = cast(sigrawdata(p).numericdata(:,n), 'double');
                    simdata(p).signals(n).dimensions = 1;
                end
            end

            signalEditorData = struct();
            scenario{numSheets} = '';
            for p = 1:length(sigrawdata)
                scenario{p} = Simulink.SimulationData.Dataset;
                % % 小数点3桁に丸める
                time = round(sigrawdata(p).data(:,1), 3);
                for n = 2:length(sigrawdata(p).labels)
                    data = sigrawdata(p).data(:,n);
                    if isempty(obj.Ts)
                        % 従来挙動
                        signal = timeseries(data, time);
                    else
                        % ZOH 等間隔化
                        signal = TP2SignalEditorCls.resampleZOH(time, data, obj.Ts);
                    end
                    signal.TimeInfo.Format = '%5.4g';
                    signal.Name = sigrawdata(p).labels{n};
                    signal.DataInfo.Interpolation = 'zoh';
                    scenario{p} = scenario{p}.addElement(signal);
                end
                
                % for n = 2:length(sigrawdata(p).labels)
                %     data = sigrawdata(p).data(:,n);
                %     signal = timeseries(data, time);
                %     signal.TimeInfo.Format = '%5.4g';
                %     signal.Name = sigrawdata(p).labels{n};
                %     signal.DataInfo.Interpolation = 'zoh';%stair状
                %     scenario{p} = scenario{p}.addElement(signal);
                % end
                scenarioNameRaw = sheets{p};
                % 日本語シート名対応
                scenarioName = matlab.lang.makeValidName(scenarioNameRaw);
                signalEditorData.(scenarioName) = scenario{p};
                % 日本語シート名対応
                % 対応不可
                % scenarioKey = sprintf('Scenario%d', p);   % ← MATLAB安全名
                % scenario{p}.Name = sheets{p};             % ← 日本語シナリオ名（表示用）
                % signalEditorData.(scenarioKey) = scenario{p};
            end

            matfile = [obj.XlsFile '.mat'];
            save(matfile, '-struct', 'signalEditorData');

            % Excelファイル名から拡張子を除いた名前を取得
            % [~, modelName, ~] = fileparts(obj.XlsFile);
            % 日本語のEXCELブック名対応
            [~, modelNameRaw, ~] = fileparts(obj.XlsFile);
            modelName = matlab.lang.makeValidName(modelNameRaw);
            if ~bdIsLoaded(modelName)
                new_system(modelName);
            end
            open_system(modelName);
            blockPath = [modelName, '/', modelName];
            add_block('simulink/Sources/Signal Editor', blockPath, 'MakeNameUnique', 'on');
            se_handle = find_system(gcs, 'FindAll', 'on', 'BlockType', 'SubSystem', 'MaskType', 'SignalEditor');
            set_param(se_handle, 'FileName', matfile);
            save_system(modelName);
        end
    end
    
    methods (Static)
        function ts = resampleZOH(time, data, Ts)
            % ZOH リサンプリング（Time重複対応）
            % === ① Time重複除去（最初の出現を採用） ===
            % 最後の行を有効にする方法
            [timeUniq, ia] = unique(time, 'last');
            dataUniq = data(ia, :);
            % === ② 等間隔 ZOH ===
            tStart = timeUniq(1);
            tEnd   = timeUniq(end);
            tNew   = (tStart:Ts:tEnd).';
            dataNew = interp1(timeUniq, dataUniq, tNew, 'previous', 'extrap');

            ts = timeseries(dataNew, tNew);
        end

        % function ts = resampleZOH(time, data, Ts)
        %     % ZOH リサンプリング
        %     tStart = time(1);
        %     tEnd   = time(end);
        %     tNew   = (tStart:Ts:tEnd).';
        %     dataNew = interp1(time, data, tNew, 'previous', 'extrap');
        %     ts = timeseries(dataNew, tNew);
        % end

        function sigrawdata = getSignalFromRaw(inData, keywd)
            sigrawdata = struct('name', {}, 'row', {}, 'data', {}, 'labels', {}, 'datatypes', {}, 'numericdata', {});
            numRows = size(inData, 1);
            i = 1;
            idx = 1;

            while i <= numRows
                if ischar(inData{i, 1}) && contains(inData{i, 1}, keywd)
                    sigrawdata(idx).name = inData{i, 1};

                    if i + 1 <= numRows
                        sigrawdata(idx).labels = inData(i + 1, :);
                    else
                        sigrawdata(idx).labels = {};
                    end

                    j = i + 2;
                    dataRows = [];
                    while j <= numRows && ~ischar(inData{j, 1})
                        dataRows = [dataRows; cell2mat(inData(j, :))];
                        j = j + 1;
                    end

                    sigrawdata(idx).data = dataRows;
                    sigrawdata(idx).row = size(dataRows, 1);
                    sigrawdata(idx).numericdata = dataRows;

                    idx = idx + 1;
                    i = j;
                else
                    i = i + 1;
                end
            end
        end
    end
end
