classdef TP2WaveFormCls2
	% editor = TP2WaveFormCls('TV3.xlsx', '1:5', 'TV3.txt');editor.process();
	% TV3.xlsx
	% Time,入力１,出力１,出力２,観点
	% TV3.txt
	% TC1,in,出力１,出力２
	% TC2,出力１
    properties
        XlsFile
        SignalRange
        SheetSignalMap % Map型：シート名 → 信号名セル配列
        % SignalList  % プロット対象の信号名リスト
    end

    methods
        function obj = TP2WaveFormCls2(xlsfile, signalRange, signalListFile)
            tic;
            warning off;
            obj.XlsFile = xlsfile;
            obj.SignalRange = signalRange;
            % 信号リストファイルの読み込み（シート名ごとの信号指定）
            obj.SheetSignalMap = containers.Map();

            % テキストファイルから信号リストを読み込む
            fid = fopen(signalListFile, 'r');
            if fid == -1
                error('Signal list file cannot be opened.');
            end
            while ~feof(fid)
                line = fgetl(fid);
                if ischar(line) && ~isempty(strtrim(line))
                    parts = strtrim(strsplit(line, ','));
                    sheetName = parts{1};
                    signals = strtrim(parts(2:end));
                    obj.SheetSignalMap(sheetName) = signals;
                end
            end
            fclose(fid);
        end

%% 
function popoutFigure(obj, time, data, sigIdx, sigName, t, range, comment)
% 別 figure に拡大表示し、テキストも描画する
%
% time    : 時刻ベクトル
% data    : 信号データ行列
% sigIdx  : 拡大対象の信号列インデックス
% sigName : 信号名（文字列）
% t       : 拡大の中心時刻
% range   : 拡大量 (例: 0.01 → ±0.01s)
% comment : Excel コメント（ラベル用）

    xmin = max(t - range, 0);
    xmax = min(t + range, max(time));
    % ループのたびに別ウィンドウが開いて消えなくする
    fig1 = figure('Name', sprintf('拡大表示_%s_t%.3f', sigName, t), ...
             'NumberTitle','off');
    fig1.Position = [0 100 2000 500];
    ax = axes(fig1);
    hold(ax, 'on');
    stairs(time, data(:, sigIdx)); % 青点付き
    grid on;
        % --- グリッドを薄い灰色に変更 ---
    colorNum=0.5;
    ax.XColor = [colorNum colorNum colorNum]; % 薄めの灰色
    ax.YColor = [colorNum colorNum colorNum];

    title(sprintf('%s 拡大表示 (%.3f 付近)', sigName, t), 'Interpreter','none');
    xlabel('Time [s]');
    ylabel(sigName, 'Interpreter','none');
    xlim([xmin xmax]);

    % Y範囲を対象データに合わせて調整
    sigSegment = data(time >= xmin & time <= xmax, sigIdx);
    if ~isempty(sigSegment)
        ymin = min(sigSegment);
        ymax = max(sigSegment);
        padding = (ymax - ymin) * 0.1; % 余白 10%
        ylim([ymin - padding, ymax + padding]);
    end

    % ===== テキスト描画 =====
    % 拡大対象時刻の値を取得
    signalValue = data(time == t, sigIdx);
    plot(t, signalValue, 'bo', 'MarkerSize', 6, 'MarkerFaceColor', 'b'); % 青点
    if isempty(signalValue)
        % t がサンプリング点にない場合、最近点を選ぶ
        [~, idxNearest] = min(abs(time - t));
        signalValue = data(idxNearest, sigIdx);
        t = time(idxNearest);
    end

    % テキストラベル作成
    labelStr = sprintf('%.3f:\n %s\n%s=%.2f', t, comment, sigName, signalValue);

    % y位置は信号値の下
    yOffset = min(sigSegment);% yOffset = (max(sigSegment)-min(sigSegment))*0.05;
    % ypos = signalValue - yOffset;
    text(t, yOffset, labelStr, ... %  text(t, ypos, labelStr, ...
        'Color', 'blue', ...
        'FontSize', 9, ...
        'VerticalAlignment', 'top', ...
        'HorizontalAlignment', 'center');
end

function popoutFigure_multi(obj, time, data, sigIdx, sigName, tCenter, tRange, tCluster, cmtCluster)
% 複数コメントを同じ拡大 Figure にプロットする
%
% time       : 時間ベクトル
% data       : データ行列 (行=時刻, 列=信号)
% sigIdx     : 対象信号の列番号
% sigName    : 信号名
% tCenter    : 拡大範囲の中心時刻
% tRange     : 拡大量 (±秒)
% tCluster   : この figure に含めるコメント時刻のベクトル
% cmtCluster : この figure に含めるコメント文字列セル配列

    % --- 拡大範囲 ---
    xmin = max(tCenter - tRange, min(time));
    xmax = min(tCenter + tRange, max(time));

    % --- Figure 作成 ---
    fig = figure('Name', ['拡大: ' sigName], 'NumberTitle','off');
    fig.Position = [100 100 800 400]; % 必要に応じて調整

    % --- 波形描画 ---
    stairs(time, data(:, sigIdx)); % 青点付き
    xlim([xmin xmax]);
    xlabel('Time (s)');
    ylabel(sigName);
    title(sprintf('%s 拡大表示 (%.3f 付近)', sigName, tCenter), 'Interpreter','none');
    grid on;
    ax = gca;
        colorNum=0.8;
    ax.XColor = [colorNum colorNum colorNum]; % 薄めの灰色
    ax.YColor = [colorNum colorNum colorNum];
    hold on;
    plot(time, data(:, sigIdx), 'bo', 'MarkerSize', 6, 'MarkerFaceColor', 'b'); % 青点

    % --- コメントを複数プロット ---
    for i = 1:length(tCluster)
        t = tCluster(i);
        cmt = cmtCluster{i};
% time ベクトルと data の対応を見つける
[~, idxTime] = min(abs(time - t));  % t に最も近い時刻のインデックス
yval = data(idxTime, sigIdx);       % sigIdx 列の値を取得
        % 信号値を取得
        yval = data(time >= t, sigIdx);
        if isempty(yval)
            yval = data(end, sigIdx);
        else
            yval = yval(1); % 最初の値を取る
        end

        % text 描画
        % テキストラベル作成
        labelStr = sprintf('%.3f:\n %s\n%s=%.2f', t, cmt, sigName, yval);
        % y位置は信号値の下
        yOffset = min(data(:, sigIdx));
        text(t, yval - yOffset, labelStr, 'Color','blue','FontSize',8, ...
             'VerticalAlignment','top','Interpreter','none');
    end

    hold off;
end

        %% 
        function process(obj)
            cols = strsplit(obj.SignalRange, ':');
            colStart = str2double(cols{1});
            colEnd   = str2double(cols{2});

            [~, sheets] = xlsfinfo(obj.XlsFile);
            numSheets = length(sheets);

            for sheetIdx = 1:numSheets
                sheetName = sheets{sheetIdx};
                disp('----------');
                fprintf('TC name=%s\n', sheetName);

                % 指定がないシートはスキップ
                if ~isKey(obj.SheetSignalMap, sheetName)
                    fprintf('スキップ: %s\n', sheetName);
                    continue;
                end

                [~, ~, raw] = xlsread(obj.XlsFile, sheets{sheetIdx});
                sigData = raw(:, colStart:colEnd);

                headers   = sigData(1, :);
                sigNames  = headers(2:end-1);  % Time列とコメント列を除いた信号名
                dataRows  = sigData(3:end, :);
                timeCol   = 1;
                commentCol = size(sigData, 2);
                signalCols = 2:(commentCol - 1);

                time  = cell2mat(sigData(3:end, timeCol));
                data  = cell2mat(sigData(3:end, signalCols));
                comments = sigData(3:end, commentCol);

                % このシートでプロットすべき信号
                targetSignals = obj.SheetSignalMap(sheetName);
                validIndices = [];
                validNames   = {};
                for i = 1:length(sigNames)
                    if any(strcmp(sigNames{i}, targetSignals))
                        validIndices(end+1) = i;
                        validNames{end+1} = sigNames{i};
                    end
                end                

                numPlots = length(validIndices);
                if numPlots == 0
                    fprintf('警告: シート %s に有効な信号がありません。\n', sheetName);
                    continue;
                end
                fig=figure('Name', ['Sheet: ' sheetName]);
                fig.Position = [0 100 2000 2000]; 
                % fig.Position = [0 100 1000 100]; 
                
                for idx = 1:numPlots
                    sigIdx = validIndices(idx);
                    subplot(numPlots, 1, idx);
                    stairs(time, data(:, sigIdx));

                    ax1 = gca;
                    colorNum=0.9;
                    ax1.XColor = [colorNum colorNum colorNum]; % 薄めの灰色
                    ax1.YColor = [colorNum colorNum colorNum];

                    ylabel(validNames{idx}, 'Interpreter', 'none');
                    title([validNames{idx}], 'Interpreter', 'none');
                    grid on;
                    hold on;

                    for j = 1:length(comments)
                        comment = comments{j};
                        t = time(j);
                        if ischar(comment) || isstring(comment)
                            if contains(comment, '[操作]') && contains(comment, validNames{idx})
                                xline(t, '--');
                                % 信号のその時点の値を取得
                                signalValue = data(j, sigIdx);  % j番目の時刻での該当信号値
                                % コメントの位置だけに点を描画
                                plot(t, signalValue, '-o', 'MarkerSize', 6, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
labelStr = sprintf('%.3f:\n %s\n%s=%.2f', t, comment, validNames{idx}, signalValue);
                % タグを削除して短くする
            labelStr = regexprep(labelStr, '\[.*?\]', ''); 
ypos = signalValue;  % y位置は信号値と一致させると見やすい

% 縦方向のオフセットを追加し見やすくする
yOffset = max(data(:,sigIdx));
% テキスト描画（位置やフォントなど調整可）
 % 'red'、'green'、'blue'、'cyan'、'magenta'、'yellow'、'black'、'white'
text(t, yOffset, labelStr, ...
    'Color', 'black', ...
    'FontSize', 8, ...
    'VerticalAlignment', 'bottom', ...
    'Rotation', -0);  % 縦書き風（任意）                                
                            end
                            if contains(comment, '[観点]') && contains(comment, validNames{idx})
                                xline(t, '--b');
                                signalValue = data(j, sigIdx);  % j番目の時刻での該当信号値
                                plot(t, signalValue, 'bo', 'MarkerSize', 6, 'MarkerFaceColor', 'b'); % 青点
                                % fprintf('Time=%.4f: %s | %s=%.4f\n', t, comment, validNames{idx}, signalValue);   
                                % 信号値を取得してラベルとして表示
% labelStr = sprintf('%.3f: %s%s=%.2f', t, comment, validNames{idx}, signalValue);
labelStr = sprintf('%.3f:\n %s\n%s=%.2f', t, comment, validNames{idx}, signalValue);
labelStr = erase(labelStr, '[観点]');
ypos = signalValue;  % y位置は信号値と一致させると見やすい
yOffset = min(data(:, sigIdx));
% テキスト描画（位置やフォントなど調整可）
text(t, yOffset, labelStr, ... % text(t, ypos - yOffset, labelStr, ...
    'Color', 'blue', ... 
    'FontSize', 8, ...
    'VerticalAlignment', 'top', ...
    'Rotation', -0);  % 縦書き風（任意）

                            end
                        end
                    end % for j = 1:length(comments)
                    if idx == numPlots
                        xlabel('Time');
                    end
                    hold off;
                end % for idx = 1:numPlots

% % ====== 2回目のループ: 拡大表示 ======
range = 0.025; % 拡大量 (±25ms)

for idx = 1:numPlots
    sigIdx  = validIndices(idx);   % 今の信号のインデックス
    sigName = validNames{idx};     % 今の信号名
    % --- まず拡大コメントを抽出 ---
    expandTimes = [];
    expandComments = {};
    for j = 1:length(comments)
        comment = comments{j};
        % NaN の場合はスキップ
        if isnan(comment)
            continue;
        end    
        if ischar(comment) && contains(comment, '[拡大]') && contains(comment, sigName)
            expandTimes(end+1)    = time(j);
            expandComments{end+1} = regexprep(comment, '\[.*?\]', ''); % タグ除去
        end
    end
    if isempty(expandTimes)
        continue;
    end    
    % --- 時間順にソート ---
    [expandTimes, sortIdx] = sort(expandTimes);
    expandComments = expandComments(sortIdx);
    % --- クラスタリング ---
    clusters = {};  % 各クラスタ = struct('times', [], 'comments', {})
    cluster = struct('times', [], 'comments', {});
    for k = 1:length(expandTimes)
        if isempty(cluster)
        % if isempty(cluster.times)
            % 最初のクラスタ開始
            cluster(1).times    = expandTimes(k);
            cluster(1).comments = {expandComments{k}};
        else
            % 直前のクラスタと距離チェック
            if expandTimes(k) - cluster(1).times(end) <= range
                % 同じクラスタに追加
                cluster(1).times(end+1)    = expandTimes(k);
                cluster(1).comments{end+1} = expandComments{k};
            else
                % 新しいクラスタ開始
            clusters{end+1} = cluster;
            cluster = struct('times', expandTimes(k), ...
                             'comments', {expandComments(k)});
            end
        end
    end    
if ~isempty(cluster.times)
    clusters{end+1} = cluster; % 最後のクラスタ追加
end
% --- 各クラスタごとに拡大figureを描画 ---
for c = 1:length(clusters)
    tCluster = clusters{c}.times;
    cmtCluster = clusters{c}.comments;

    % ここではクラスタの最小・最大時刻を基準に範囲を決める
    tCenterRaw = mean([min(tCluster), max(tCluster)]);
    % 0.005刻みに丸める
    tCenter = round(tCenterRaw / 0.005) * 0.005;
    tRange  = range; % or 少し広めにとる
    obj.popoutFigure_multi(time, data, sigIdx, sigName, ...
                           tCenter, tRange, ...
                           tCluster, cmtCluster);
end
%         % comment = comments{j};
%         % コメントに [拡大] が含まれていて、かつ信号名が一致する場合のみ
%         % if contains(comment, '[拡大]') && contains(comment, sigName)
%         %     t = time(j);   % コメントの時刻
%         %         % タグを削除して短くする
%         %     shortComment = regexprep(comment, '\[.*?\]', '');  
%         %     % 拡大表示（別 figure）
%         %     obj.popoutFigure(time, data, sigIdx, sigName, t, range, ...
%         %         shortComment);
%         % end
%     end
end
                
            end
            toc;
        end
    end
end