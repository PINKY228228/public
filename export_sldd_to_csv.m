function export_sldd_to_csv(slddPath)
% SLDD_TO_CSV
%   指定した Simulink Data Dictionary (.sldd) 内の変数情報を
%   CSV ファイルに出力する
%
% 入力:
%   slddPath : パスを含む .sldd ファイル名
%              例) 'C:\work\model\data\example.sldd'
%
% 出力:
%   sldd と同じフォルダに CSV を生成
%     example.sldd → example_variables.csv
% export_sldd_to_csv('plc_sldd_ex.sldd') 

    arguments
        slddPath (1,:) char
    end

    %% ---- ファイルチェック ----
    if ~isfile(slddPath)
        error('指定した sldd ファイルが存在しません: %s', slddPath);
    end

    %% ---- 出力 CSV 名 ----
    [folder, name] = fileparts(slddPath);
    csvFile = fullfile(folder, [name '_variables.csv']);

    %% ---- SLDD を開く ----
    dd = Simulink.data.dictionary.open(slddPath);
    cleanupObj = onCleanup(@() close(dd));  % 確実にクローズ

    sect = getSection(dd, 'Design Data');
    entries = find(sect);

    %% ---- 出力ヘッダ ----
    header = { ...
        'VariableName', ...
        'Value', ...
        'DataType', ...
        'Class', ...
        'Size', ...
        'Description'};

    out = cell(length(entries)+1, numel(header));
    out(1,:) = header;

    %% ---- 各変数を処理 ----
    for i = 1:length(entries)
        e = entries(i);
        nameVar = e.Name;%getName(e);
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
                valueStr = '[object]';
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
            sz = size(val);
            sizeStr = mat2str(sz);
        catch
            sizeStr = '-';
        end

        % 説明
        try
            desc = e.Description;
        catch
            desc = '';
        end

        % CSV 行
        out{i+1,1} = nameVar;
        out{i+1,2} = valueStr;
        out{i+1,3} = dataType;
        out{i+1,4} = class(val);
        out{i+1,5} = sizeStr;
        out{i+1,6} = desc;
    end

    %% ---- CSV 書き出し ----
    writecell(out, csvFile, 'Encoding', 'UTF-8');

    fprintf('CSV 出力完了:\n  %s\n', csvFile);
end