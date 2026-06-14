function createSFunctionBuilder(sfunName)
% createSFunctionBuilder("test")
modelName = bdroot;

if isempty(modelName)
    error('No model is open.');
end

blkPath = modelName + "/" + sfunName;

%% Block existence check

existBlk = find_system(...
    modelName,...
    'SearchDepth',1,...
    'Name',sfunName);

if ~isempty(existBlk)

    error(...
        'S-Function Builder "%s" already exists.',...
        sfunName);

end

%% Create S-Function Builder

add_block(...
    'simulink/User-Defined Functions/S-Function Builder',...
    blkPath,...
    'Position',[400 150 550 250]);

%% Top-level Inports

inports = find_system(...
    modelName,...
    'SearchDepth',1,...
    'BlockType','Inport');

%% Top-level Outports

outports = find_system(...
    modelName,...
    'SearchDepth',1,...
    'BlockType','Outport');

%% Add Inputs

for idx = 1:numel(inports)

    sigName = string(get_param(inports{idx},'Name'));

    Simulink.SFunctionBuilder.add(...
        blkPath,...
        "Input",...
        Name=sigName,...
        DataType=getDataType(sigName),...
        Dimensions="[1,1]");

end

%% Add Outputs

for idx = 1:numel(outports)

    sigName = string(get_param(outports{idx},'Name'));

    Simulink.SFunctionBuilder.add(...
        blkPath,...
        "Output",...
        Name=sigName,...
        DataType=getDataType(sigName),...
        Dimensions="[1,1]");

end

fprintf('\n');
fprintf('=====================================\n');
fprintf('S-Function Builder Generated\n');
fprintf('Model   : %s\n', modelName);
fprintf('Block   : %s\n', sfunName);
fprintf('Inputs  : %d\n', numel(inports));
fprintf('Outputs : %d\n', numel(outports));
fprintf('=====================================\n');

end


function dt = getDataType(sigName)

if startsWith(sigName,"gu8")

    dt = "uint8";

elseif startsWith(sigName,"gu16")

    dt = "uint16";

else

    error(...
        'Unsupported signal name : %s',...
        sigName);

end

end