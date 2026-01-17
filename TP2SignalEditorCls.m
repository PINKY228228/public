classdef TP2SignalEditorCls
% (使用例)
% testPatternSimple.xlsxファイルの左端から3列目（Time列含む）までを入力データとしたい場合
% % TP2SignalEditor クラスをインスタンス化;データを処理
% editor = TP2SignalEditorCls('testPatternSimple.xlsx', '1:3');editor.process();
    properties
        XlsFile
        SignalRange
    end
    
    methods
        function obj = TP2SignalEditorCls(xlsfile, SignalRange)
            obj.XlsFile = xlsfile;
            obj.SignalRange = SignalRange;
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
                % 小数点3桁に丸める
                time = round(sigrawdata(p).data(:,1), 3);   
                for n = 2:length(sigrawdata(p).labels)
                    data = sigrawdata(p).data(:,n);
                    signal = timeseries(data, time);
                    signal.TimeInfo.Format = '%5.4g';
                    signal.Name = sigrawdata(p).labels{n};
                    signal.DataInfo.Interpolation = 'zoh';%stair状
                    scenario{p} = scenario{p}.addElement(signal);
                end
                scenarioName = sheets{p};
                signalEditorData.(scenarioName) = scenario{p};
            end

            matfile = [obj.XlsFile '.mat'];
            save(matfile, '-struct', 'signalEditorData');

            % Excelファイル名から拡張子を除いた名前を取得
            [~, modelName, ~] = fileparts(obj.XlsFile);
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
