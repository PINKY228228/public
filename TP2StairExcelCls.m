classdef TP2StairExcelCls
% Time列：1列目固定
% "SUT_ID"：完全一致
% 無い場合：そのシートはスキップ（何もしない）
% TP2StairExcelCls('testPatternSimple3_.xlsx').process();    
    properties
        InFile
        OutFile
    end

    methods
        function obj = TP2StairExcelCls(inFile)
            obj.InFile = inFile;
            % 出力ファイル名（最後の1文字削る）
            [path, name, ext] = fileparts(inFile);
            name2 = name(1:end-1);
            obj.OutFile = fullfile(path, [name2 ext]);
        end

        function process(obj)
            tic;
            [~, sheets] = xlsfinfo(obj.InFile);

            for iSheet = 1:length(sheets)
                [~,~,raw] = xlsread(obj.InFile, sheets{iSheet});

                % ===== ヘッダ取得 =====
                headers = raw(1,:);

                % SUT_ID列検索
                idx = find(strcmp(headers, 'SUT_ID'), 1);

                % 無ければスキップ
                if isempty(idx)
                    continue;
                end

                % ===== 範囲決定 =====
                % データ（Time～SUT_IDの1つ前）
                dataRaw = raw(2:end, 1:idx-1);

                % 出力ヘッダ（Time～SUT_IDの右1列まで）
                headerOut = raw(1, 1:min(idx+1, size(raw,2)));

                % ===== 数値化 =====
                data = cell2mat(dataRaw);
                time = data(:,1);
                values = data(:,2:end);

                % ===== 出力バッファ =====
                out = [];
                lastRow = [];

                % ===== 2行化処理 =====
                for i = 1:length(time)-1
                    t_now = time(i);
                    t_next = time(i+1);

                    v_now = values(i,:);
                    v_next = values(i+1,:);

                    [out, lastRow] = TP2StairExcelCls.addRows(out, lastRow, [t_now, v_now]);
                    [out, lastRow] = TP2StairExcelCls.addRows(out, lastRow, [t_next, v_now]);
                    if any(v_now ~= v_next)
                        [out, lastRow] = TP2StairExcelCls.addRows(out, lastRow, [t_next, v_next]);
                    end
                end
                % ===== Excel出力 =====
                nHeader = size(headerOut, 2);
                nData   = size(out, 2);
                if nHeader > nData
                    pad = cell(size(out,1), nHeader - nData);
                    outCellData = [num2cell(out), pad];
                else
                    outCellData = num2cell(out);
                end
                outCell = [headerOut; outCellData];

                writecell(outCell, obj.OutFile, 'Sheet', sheets{iSheet});
            end
            toc;
        end

    end

    methods (Static)        
        function [out, lastRow] = addRows(out, lastRow, row)
            if isempty(lastRow) || any(lastRow ~= row)
                out = [out; row];
            lastRow = row;
            end
        end
    end
end