classdef importMatToSDICls
    % ① MAT投入
    % importMatToSDICls.importMatToSDI2;
    % ② run 比較
    % importMatToSDICls.compareRunByName('TC6_.xlsx_TC1_ideal','ToFileName_1');
    % importMatToSDICls.compareRunByName('TC6_.xlsx_TC1_ideal','o_1');
    % レポート出力
    % importMatToSDICls.compareRunByName('TC6_.xlsx_TC3_ideal','ToFileName_3','TC3');
    % importMatToSDICls.compareRunByName('TC6_.xlsx_TC3_ideal','o_3','TC3');
    % importMatToSDICls.compareRunByName('TC6_.xlsx_TC3_ideal','test','TC3'); %手動でtest.matをインポート時⇒比較されない
    methods(Static)

%% ===== MAT → SDI =====
    function importMatToSDI2(folderPath)
        clc;
        if nargin == 0
            folderPath = pwd;
        end

        Simulink.sdi.clear;
        files = dir(fullfile(folderPath, '*.mat'));

        for k = 1:numel(files)
            filePath = fullfile(folderPath, files(k).name);
            disp(files(k).name)

            try
                data = load(filePath);
                fn = fieldnames(data);

                [~, baseRunName, ~] = fileparts(files(k).name);

            if numel(fn) > 1
                % ===== 複数TC =====
                    % 【理由】
    % MATファイル内に複数のトップレベル変数（=複数TC）が格納されているため、
    % 各TCごとに独立したRunとしてSDIへ登録する。
    %
    % 【期待するデータ構造】
    % data (struct)
    %  ├ TC1 : Simulink.SimulationData.Dataset
    %  │       └ TEST (Dataset)
    %  │           ├ gu8o1_ideal  (Signal)
    %  │           ├ gs16o2_ideal (Signal)
    %  │           └ ...
    %  ├ TC2 : Simulink.SimulationData.Dataset
    %  │       └ TEST (Dataset)
    %  │           └ ...
    %  └ ...
    %
    % ※各フィールド名（TC1, TC2, ...）がテストケース名
    % ※中身はDatasetであることを前提とする
    %
    % 【処理内容】
    % ・各TCを1つずつ取り出す
    % ・"_ideal" を含む信号のみ抽出（期待値のみ残す）
    % ・信号名から "ideal" を除去（比較用に名前を統一）
    % ・1TC = 1Run としてSDIへ登録
                for i = 1:numel(fn)
                    tcName = fn{i};
                    TEST = data.(tcName);

                    for j = TEST.numElements:-1:1
                        if contains(TEST{j}.Name, '_ideal')
                            TEST{j}.Name = erase(TEST{j}.Name, 'ideal');
                        else
                            TEST = TEST.removeElement(j);
                        end
                    end

                    runName = sprintf('%s_%s_ideal', baseRunName, tcName);
                    Simulink.sdi.createRun(runName, 'vars', TEST);
                end

            else
                % ===== 単一TC =====
                % 【理由】
    % MATファイル内にトップレベル変数が1つのみであり、
    % SimulinkのToFileログ形式（struct + timeseries）で格納されているため、
    % SDIで比較可能な形式（Dataset）へ変換する。
    %
    % 【期待するデータ構造】
    % data (struct)
    %  └ TEST (struct)
    %       ├ gu8o1_ : timeseries
    %       │    ├ Time : [Nx1 double]
    %       │    └ Data : [Nx1 double / int]
    %       ├ gs16o2_ : timeseries
    %
    % 【変換後（SDI投入時）の構造】
    % Dataset
    %  ├ gu8o1_  (Signal)
    %  │    └ Values : timeseries
    %  ├ gs16o2_
    %
    % 【処理内容】
    % ・struct(TEST) を Dataset に変換（Signal + timeseries）
    % ・"_ideal" を含む信号は除外（比較対象のみ残す）
    % ・1ファイル = 1Run としてSDIへ登録
    %
    % 【前提】
    % ToFileログ形式の変数名:TEST
    % ・各フィールドは timeseries 型であること
    % ・信号名はベースラインと対応可能な命名であること
                TEST = importMatToSDICls.struct2dataset(data.TEST);

                for i = TEST.numElements:-1:1
                    if contains(TEST{i}.Name, '_ideal')
                        TEST = TEST.removeElement(i);
                    end
                end

                Simulink.sdi.createRun(baseRunName, 'vars', TEST);
            end

            catch ME
                warning('Failed: %s (%s)', files(k).name, ME.message);
            end
        end
    end

%% ===== struct → Dataset =====
    function ds = struct2dataset(s)

        ds = Simulink.SimulationData.Dataset;
        fn = fieldnames(s);

        for i = 1:numel(fn)
            name = fn{i};
            ts = s.(name);

            sig = Simulink.SimulationData.Signal;
            sig.Name = name;
            sig.Values = ts;

            ds = ds.addElement(sig);
        end
    end

%% ===== Run比較 =====
function compareRunByName(baseName, cmpName, reportFile)

    %% ===== Run取得 =====
    runIDs = Simulink.sdi.getAllRunIDs;

    id_base = [];
    id_cmp  = [];

    for i = 1:length(runIDs)
        r = Simulink.sdi.getRun(runIDs(i));

        if strcmp(r.Name, baseName)
            id_base = runIDs(i);
        elseif strcmp(r.Name, cmpName)
            id_cmp = runIDs(i);
        end
    end

    if isempty(id_base) || isempty(id_cmp)
        error('Runが見つからない');
    end

    %% ===== 信号名揃え =====
    run1 = Simulink.sdi.getRun(id_base);
    run2 = Simulink.sdi.getRun(id_cmp);

    sigs1 = run1.getAllSignals;
    sigs2 = run2.getAllSignals;

    for i = 1:length(sigs2)
        name2 = sigs2(i).Name;

        for j = 1:length(sigs1)
            name1 = sigs1(j).Name;

            % ★安全寄り
            if endsWith(name2, name1) || endsWith(name1, name2)
                sigs2(i).Name = name1;
                break;
            end
        end
    end

    %% ===== 比較 =====
    result = Simulink.sdi.compareRuns(id_base, id_cmp);

    %% ===== レポート出力 =====
    if nargin >= 3 && ~isempty(reportFile)

        % 拡張子補完
        if ~contains(reportFile, '.zip')
            reportFile = [reportFile '.zip'];
        end

        % report APIが使えるかチェック
        if exist('Simulink.sdi.report','class') == 8

            rpt = Simulink.sdi.report(result);
            rpt.FileName = reportFile;
            rpt.Title = sprintf('比較: %s vs %s', baseName, cmpName);
            rpt.IncludeOnlyMismatchedSignals = true;

            generate(rpt);

            fprintf('SDI report exported: %s\n', reportFile);

        else
            % フォールバック（確実）
            warnMsg = 'report API未対応 → mldatx保存にフォールバック'
            warning(warnMsg);
            % Simulink.sdi.save(strrep(reportFile,'.zip','.mldatx'));
             Simulink.sdi.report('ReportType','Compare', 'ReportTitle',...
    [baseName ' vs ' cmpName '_results'],'ReportAuthor', 'Mie','ReportOutputFile',strrep(reportFile,'.zip', ''));
        end
    end
end
end
end