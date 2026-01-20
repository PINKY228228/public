classdef ExcelZOHExpanderCLS
% expander = ExcelZOHExpanderCLS('TV2.xlsx', '1:5');outFile = expander.writeExcel();    
    properties
        inFile
        colRange        % 例 '1:5'
        Ts = 0.01
        blankMask
        sheetNames
    end

    methods
        function obj = ExcelZOHExpanderCLS(inFile, colRange)
            obj.inFile   = inFile;
            obj.colRange = colRange;
            obj.sheetNames = sheetnames(inFile);
        end

        %==============================
        function outFile = writeExcel(obj)
            [p,name,~] = fileparts(obj.inFile);
            outFile = fullfile(p,[name '_zoh.xlsx']);

            for s = 1:numel(obj.sheetNames)
                sheet = obj.sheetNames{s};

                raw = readcell(obj.inFile,'Sheet',sheet,'MissingRule','fill');
                header = raw(1,:);
                T      = obj.fixMissing(raw(2:end,:));

                obj.blankMask = obj.makeBlankMask(size(T,2));

                T_out = obj.expandOneSheet(T);
                out   = [header; T_out];

                writecell(out,outFile,'Sheet',sheet);
            end
        end
    end

    methods (Access = private)
        %==============================
        function blankMask = makeBlankMask(obj,nCol)
            cols = eval(obj.colRange);   % 例 1:5
            blankMask = true(1,nCol);
            blankMask(cols) = false;     % 指定範囲は残す
            blankMask(1)    = false;     % Time列は必ず残す
        end

        %==============================
        function T_out = expandOneSheet(obj,T)
            Time = cell2mat(T(:,1));
            nRow = size(T,1);

            T_out = {};

            for i = 1:nRow
                % ---- 通常コピー ----
                T_out = [T_out; T(i,:)];

                if i < nRow
                    dt = Time(i+1) - Time(i);
                    if dt > obj.Ts
                        row2 = T(i,:);
                        for c = find(obj.blankMask)
                            row2{c} = '';
                        end
                        T_out = [T_out; row2];
                    end
                else
                    % ---- 最終行：必ずもう1回コピー ----
                    row2 = T(i,:);
                    for c = find(obj.blankMask)
                        row2{c} = '';
                    end
                    T_out = [T_out; row2];
                end
            end
        end
    end

    methods (Static)
        function C = fixMissing(C)
            for i = 1:numel(C)
                if ismissing(C{i})
                    C{i} = '';
                end
            end
        end
    end
end
