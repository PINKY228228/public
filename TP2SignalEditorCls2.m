classdef TP2SignalEditorCls2
% ① まず MAT ファイルをロード
% s=load('TC6_.xlsx.mat')
% s = 
%   フィールドをもつ struct:
%     TC1: [1×1 Simulink.SimulationData.Dataset]
% ② シナリオ名を確認
% fieldnames(s)
% ans =
%   3×1 の cell 配列
%     {'TC1'}
% ③ Dataset を取得
% ds = s.TC1
% ds = 
%                              名前  BlockPath 
%                              __  _________ 
%     1  [1x1 timeseries]      i1  ''       
% ④ 各信号の型を確認
% class(ds{1}.Data)
% ans =
%     'uint8'
% (使用例)
% TC6_.xlsxファイルの左端（Time列）から'SUT_ID'列の一つ前までを入力データとし、
% 0.01[s]間隔でmatファイル化する場合
% % TP2SignalEditor クラスをインスタンス化;データを処理
% editor = TP2SignalEditorCls2('TC6_.xlsx',0.01);editor.process();    
    properties
        XlsFile
        Ts          % [] or scalar
        KeyWord = 'SUT_ID'; % データ範囲と範囲外を切り分けるため、ヘッダ行へ記載するキーワード
    end
    
    methods
        function obj = TP2SignalEditorCls2(xlsfile, Ts)
            obj.XlsFile = xlsfile;
            if nargin < 2 || isempty(Ts)
                obj.Ts = [];
            else
                obj.Ts = Ts;
            end
        end

        function process(obj)
            tic;
            warning off;
            raw = [];
            [~, sheets] = xlsfinfo(obj.XlsFile);
            numSheets = length(sheets);

            for iSheet = 1:numSheets
                [~,~,iRaw] = xlsread(obj.XlsFile, sheets{iSheet});

                % ===== ヘッダ行から列範囲自動判定 =====
                header = iRaw(1,:); % ラベル行
                sutIdx = find(strcmp(header, obj.KeyWord), 1);

                if isempty(sutIdx)
                    error('SUT_ID列が見つからない');
                end

                c1 = 1;              % Time列（前提）
                c2 = sutIdx - 1;     % KeyWordの1つ前まで

                iRaw = iRaw(:, c1:c2);

                % ===== 列数統一 =====
                numCols = size(iRaw, 2);
                activeGroupName = cell(1, numCols);
                activeGroupName{1,1} = ['<TV>' sheets{iSheet}];

                raw = vertcat(raw, activeGroupName, iRaw);
            end

            inData = raw;

            keywd = '<TV>';
            sigrawdata = obj.getSignalFromRaw(inData, keywd);

            TestCaseName{numSheets} = '';
            for p = 1:length(sigrawdata)
                TestCaseName{p} = sigrawdata(p).name;
                simdata(p).time = sigrawdata(p).numericdata(:,1);

                for n = 1:length(sigrawdata(p).labels)
                    simdata(p).signals(n).label = sigrawdata(p).labels{n};
                    simdata(p).signals(n).values = cast(sigrawdata(p).numericdata(:,n), 'double');
                    simdata(p).signals(n).dimensions = 1;
                end
            end

            signalEditorData = struct();
            scenario{numSheets} = '';

            for p = 1:length(sigrawdata)
                scenario{p} = Simulink.SimulationData.Dataset;

                % 小数点2桁に丸める
                time = round(sigrawdata(p).data(:,1), 2);

                for n = 2:length(sigrawdata(p).labels)
                    data = sigrawdata(p).data(:,n);

                    if isempty(obj.Ts)
                        signal = timeseries(data, time);
                    else
                        signal = TP2SignalEditorCls2.resampleZOH(time, data, obj.Ts);
                    end

                    signal.TimeInfo.Format = '%.2f';

                    label = sigrawdata(p).labels{n};
                    [dataType, cleanName] = TP2SignalEditorCls2.parseDataTypeFromHeader(label);

                    signal.Name = cleanName;
                    signal.Data = cast(signal.Data, dataType);
                    signal.DataInfo.Interpolation = 'zoh';

                    scenario{p} = scenario{p}.addElement(signal);
                end

                scenarioNameRaw = sheets{p};
                scenarioName = matlab.lang.makeValidName(scenarioNameRaw);
                signalEditorData.(scenarioName) = scenario{p};
            end

            matfile = [obj.XlsFile '.mat'];
            save(matfile, '-struct', 'signalEditorData');

            % 日本語のEXCELブック名対応
            [~, modelNameRaw, ~] = fileparts(obj.XlsFile);
            modelName = matlab.lang.makeValidName(modelNameRaw);

            if ~bdIsLoaded(modelName)
                new_system(modelName);
            end

            open_system(modelName);

            blockPath = [modelName, '/', modelName];
            add_block('simulink/Sources/Signal Editor', blockPath, 'MakeNameUnique', 'on');

            se_handle = find_system(gcs, 'FindAll', 'on', ...
                'BlockType', 'SubSystem', 'MaskType', 'SignalEditor');

            set_param(se_handle, 'FileName', matfile);
            save_system(modelName);
            toc;
        end
    end
    
    methods (Static)
        function [dataType, cleanName] = parseDataTypeFromHeader(label)

            dataType = 'double';
            cleanName = label;

            if ~ischar(label) && ~isstring(label)
                return
            end

            label = char(label);

            if label(1) ~= 'g'
                return
            end

            % ===== 可変長 prefix 判定 =====
            if startsWith(label, 'gfg')
                dataType = 'logical';
                cleanName = label(4:end);

            elseif startsWith(label, 'gu8')
                dataType = 'uint8';
                cleanName = label(4:end);

            elseif startsWith(label, 'gs8')
                dataType = 'int8';
                cleanName = label(4:end);

            elseif startsWith(label, 'gu16')
                dataType = 'uint16';
                cleanName = label(5:end);

            elseif startsWith(label, 'gs16')
                dataType = 'int16';
                cleanName = label(5:end);

            elseif startsWith(label, 'gu32')
                dataType = 'uint32';
                cleanName = label(5:end);

            elseif startsWith(label, 'gs32')
                dataType = 'int32';
                cleanName = label(5:end);

            elseif startsWith(label, 'gfl')
                dataType = 'single';
                cleanName = label(4:end);

            else
                return
            end
        end
                
        function ts = resampleZOH(time, data, Ts)
            % ZOH リサンプリング（Time重複対応）

            [timeUniq, ia] = unique(time, 'last');
            dataUniq = data(ia, :);

            tStart = timeUniq(1);
            tEnd   = timeUniq(end);

            tNew = round((tStart:Ts:tEnd).', 10);
            dataNew = interp1(timeUniq, dataUniq, tNew, 'previous', 'extrap');

            ts = timeseries(dataNew, tNew);
        end

        function sigrawdata = getSignalFromRaw(inData, keywd)

            sigrawdata = struct('name', {}, 'row', {}, 'data', {}, ...
                                'labels', {}, 'datatypes', {}, 'numericdata', {});

            numRows = size(inData, 1);
            i = 1;
            idx = 1;

            while i <= numRows
                if ischar(inData{i,1}) && contains(inData{i,1}, keywd)

                    sigrawdata(idx).name = inData{i,1};

                    if i + 1 <= numRows
                        sigrawdata(idx).labels = inData(i + 1, :);
                    else
                        sigrawdata(idx).labels = {};
                    end

                    j = i + 2;
                    dataRows = [];

                    while j <= numRows && ~ischar(inData{j,1})
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