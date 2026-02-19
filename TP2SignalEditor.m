function TP2SignalEditor(xlsfile,SignalRange)
% (使用例)
% testPatternSimple.xlsxファイルの左端から3列目（Time列含む）までを入力データとしたい場合
% TP2SignalEditor('testPatternSimple.xlsx', '1:3');
% ① まず MAT ファイルをロード
% s=load('testPatternSimple3.xlsx.mat')
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

column = strsplit(SignalRange, ':');
raw = [];
[~, sheets] = xlsfinfo(xlsfile);
% Excelシート数
numSheets = length(sheets);

for iSheet=1:length(sheets)
    % xls2SignalBuilder  Create SignalBuilder block from Excel selection
    [~,~,iRaw]= xlsread(xlsfile,sheets{iSheet});
    [~, numCols] = size(iRaw);
    activeGroupName = cell(1, numCols);
    activeGroupName{1, str2double(column{1})} = ['<TV>' sheets{iSheet}];
    raw = vertcat(raw, activeGroupName, iRaw);
end

inData = raw;
[~, numCols] = size(inData);

if str2double(column{2}) < numCols
    for iColumn=1:numCols-str2double(column{2})
        % 
        inData(:, numCols - iColumn + 1) = [];
    end
end

if str2double(column{1}) > 1
    for iColumn=0:str2double(column{1})-1
        % 
        inData(:, iColumn) = [];
    end
end

% Regular expression keywd defines the beggining of signal
keywd = '<TV>';
sigrawdata = getSignalFromRaw(inData,keywd);
TestCaseName{numSheets} = '';
for p=1:length(sigrawdata)
    TestCaseName{p} = sigrawdata(p).name;
    % Define as time with structure data format
    simdata(p).time = sigrawdata(p).numericdata(:,1);
    for n=1:length(sigrawdata(p).labels)
        simdata(p).signals(n).label = sigrawdata(p).labels{n};
        dType = 'double';
        simdata(p).signals(n).values = cast(sigrawdata(p).numericdata(:,n),dType);
        simdata(p).signals(n).dimensions = 1;
    end
end

%%
% 1. データセットを作成
% シナリオ用の構造体
signalEditorData = struct();

% シナリオごとにデータセットを作成
scenario{numSheets} = '';
for p = 1:length(sigrawdata)
    % シナリオごとに Dataset を作成
    scenario{p} = Simulink.SimulationData.Dataset;
    
    % 時間データを取得
    time = sigrawdata(p).data(:,1);    
    for n = 2:length(sigrawdata(p).labels)
        % シグナルデータを取得
        data = sigrawdata(p).data(:,n);
        signal = timeseries(data, time);
        signal.Name = sigrawdata(p).labels{n};
        
        % データセットに追加
        scenario{p} = scenario{p}.addElement(signal);
    end

    % シナリオ名を動的に作成
    scenarioName = sheets{p};
    signalEditorData.(scenarioName) = scenario{p};  % 構造体に格納
end

% 2. データをMATファイルに保存
matfile = [xlsfile '.mat'];
save(matfile, '-struct', 'signalEditorData');

% 3. Simulink モデルを作成または開く
modelName = 'SignalEditorModel';
if ~bdIsLoaded(modelName)
    new_system(modelName);
end
open_system(modelName);

% 4. Signal Editor ブロックを追加
blockPath = [modelName, '/SignalEditor'];
add_block('simulink/Sources/Signal Editor', blockPath, 'MakeNameUnique', 'on');

% 5. Signal Editor のシナリオを設定
  se_handle = find_system(gcs, 'FindAll', 'on', 'BlockType', 'SubSystem', 'MaskType', 'SignalEditor');
  set_param(se_handle, 'FileName', matfile);

% 6. モデルを保存
save_system(modelName);
end

function sigrawdata = getSignalFromRaw(inData, keywd)
    % シグナルデータの初期化
    sigrawdata = struct('name', {}, 'row', {}, 'data', {}, 'labels', {}, 'datatypes', {}, 'numericdata', {});

    % 行数を取得
    numRows = size(inData, 1);
    i = 1;
    idx = 1;

    while i <= numRows
        % キーワード（例：<TV>TC1, <TV>TC2）を探す
        if ischar(inData{i, 1}) && contains(inData{i, 1}, keywd)
            sigrawdata(idx).name = inData{i, 1};

            % **(修正) ラベル行の取得（Time列を含める）**
            if i + 1 <= numRows
                sigrawdata(idx).labels = inData(i + 1, :); % **1列目から取得**
            else
                sigrawdata(idx).labels = {}; % ラベルがない場合は空にする
            end

            % データ行の取得
            j = i + 2;
            dataRows = [];
            while j <= numRows && ~ischar(inData{j, 1})
                dataRows = [dataRows; cell2mat(inData(j, :))]; % **1列目から取得**
                j = j + 1;
            end

            sigrawdata(idx).data = dataRows;
            sigrawdata(idx).row = size(dataRows, 1);
            sigrawdata(idx).numericdata = dataRows; % **Timeを含むデータ**

            % 次のグループへ
            idx = idx + 1;
            i = j;
        else
            i = i + 1;
        end
    end
end