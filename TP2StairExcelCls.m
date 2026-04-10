classdef TP2StairExcelCls
% SignalRangeで指定する列はすべて数値であること
% （コメント列は含めないこと）
% TP2StairExcelCls('testPatternSimple3.xlsx','testPatternSimple3_.xlsx','1:5').process();    
    properties
        InFile
        OutFile
        SignalRange   % 例: '1:5'
    end

    methods
        function obj = TP2StairExcelCls(inFile, outFile, signalRange)
            obj.InFile = inFile;
            obj.OutFile = outFile;
            obj.SignalRange = signalRange;
        end

        function process(obj)
            tic;
            col = strsplit(obj.SignalRange, ':');
            c1 = str2double(col{1});
            c2 = str2double(col{2});

            [~, sheets] = xlsfinfo(obj.InFile);

            for iSheet = 1:length(sheets)
                [~,~,raw] = xlsread(obj.InFile, sheets{iSheet});

                out = [];
                lastRow = [];
                % 指定列だけ抽出
                raw = raw(:, c1:c2);

                headers = raw(1,:);
                data = cell2mat(raw(2:end,:));

                time = data(:,1);
                values = data(:,2:end);

                out = [];

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

                % ヘッダ付きで書き込み
                outCell = [headers; num2cell(out)];
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