function export_all_sldd_to_one_csv()
% EXPORT_ALL_SLDD_TO_ONE_CSV
%   フォルダ選択ダイアログを表示し、
%   指定フォルダ配下を再帰探索して
%   すべての Simulink Data Dictionary (.sldd) を
%   1つの CSV ファイルに統合して出力する。
%
% 出力:
%   選択フォルダ直下に
%   all_sldd_variables.csv を生成

    %% ---- フォルダ選択 ----
    baseFolder = uigetdir(pwd, 'SLDD を含むフォルダを選択してください');
    if isequal(baseFolder, 0)
        disp('キャンセルされました');
        return;
    end

    %% ---- sldd 再帰探索 ----
    slddFiles = dir(fullfile(baseFolder, '**', '*.sldd'));
    if isempty(slddFiles)
        warning('指定フォルダ配下に sldd が見つかりませんでした');
        return;
    end

    fprintf('検出された sldd 数: %d\n', numel(slddFiles));

    %% ---- 出力 CSV（1ファイル） ----
    outCsvFile = fullfile(baseFolder, 'all_sldd_variables.csv');

    header = { ...
        'SLDD_File', ...
        'SLDD_RelativePath', ...
        'VariableName', ...
        'Value', ...
        'DataType', ...
        'Class', ...
        'Size', ...
        'Description'};

    % 出力セル（最初はヘッダのみ）
    out = header;

    %% ---- 各 sldd を処理 ----
    for k = 1:numel(slddFiles)

        slddPath = fullfile(slddFiles(k).folder, slddFiles(k).name);
        fprintf('\n処理中: %s\n', slddPath);

        try
            %% ---- sldd 位置情報 ----
            slddFileName = slddFiles(k).name;
            slddRelPath  = erase(slddPath, [baseFolder filesep]);

            %% ---- SLDD オープン ----
            dd = Simulink.data.dictionary.open(slddPath);
            cleanupObj = onCleanup(@() close(dd)); %#ok<NASGU>

            sect = getSection(dd, 'Design Data');
            entries = find(sect);

            %% ---- 各エントリを out に追記 ----
            for i = 1:length(entries)
                e = entries(i);
                nameVar = e.Name;
                val     = e.getValue();

                % 値の文字列化
                try
                    if isa(val,'Simulink.Parameter')
                        valueStr = mat2str(val.Value);
                    elseif isnumeric(val) || islogical(val)
                        valueStr = mat2str(val);
                    elseif ischar(val) || isstring(val)
                        valueStr = char(val);
                    elseif isstruct(val)
                        valueStr = '[struct]';
                    else
                        valueStr = ['[object:' class(val) ']'];
                    end
                catch
                    valueStr = '[unavailable]';
                end

                % データ型
                if isa(val,'Simulink.Parameter')
                    dataType = val.DataType;
                else
                    dataType = class(val);
                end

                % サイズ
                try
                    sizeStr = mat2str(size(val));
                catch
                    sizeStr = '-';
                end

                % 説明
                try
                    desc = e.Description;
                catch
                    desc = '';
                end

                % ---- 行を追加 ----
                out(end+1, :) = { ...
                    slddFileName, ...
                    slddRelPath, ...
                    nameVar, ...
                    valueStr, ...
                    dataType, ...
                    class(val), ...
                    sizeStr, ...
                    desc};
            end

        catch ME
            warning('失敗: %s\n  理由: %s', slddPath, ME.message);
        end
    end

    %% ---- CSV 書き出し ----
    writecell(out, outCsvFile, 'Encoding', 'UTF-8');

    fprintf('\nCSV 出力完了:\n  %s\n', outCsvFile);
end
