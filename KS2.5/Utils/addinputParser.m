function addinputParser(scriptFilePath, parameters)
% Read the existing script file
[folder, fname, ext] = fileparts(scriptFilePath);
if isempty(ext)
    ext = '.m';
end
scriptFilePath = fullfile(folder, strcat(fname,ext));
backupFilePath = fullfile(folder, strcat(fname, datestr(datetime, 'yymddHHMMSS'), 'backup', ext));
copyfile(scriptFilePath, backupFilePath);
fid = fopen(scriptFilePath, 'r');
existingScript = fread(fid, '*char')';
fclose(fid);
try

    % Determine the position to insert the character array
    documentStartIndex = strfind(existingScript, char(10));
    if isempty(documentStartIndex)
        insertPosition = 1;
    else
        insertPosition = documentStartIndex(1);
    end

    % Prepare the character array to be inserted with '%' at the beginning of each line
    fmt_specs = ["p = inputParser;", ...
        "p.addParameter('%s', []);", ...
        "p.parse(varargin{:});", ...
        "%s = p.Results.%s;"];
    characterArray = [existingScript(1:insertPosition-1), fmt_specs(1), cellfun(@(x) sprintf(fmt_specs(2), x), parameters), fmt_specs(3), cellfun(@(x) sprintf(fmt_specs(4), x, x), parameters), existingScript(insertPosition:end)];
    % Construct the updated script with the inserted character array
    updatedScript = [strjoin(characterArray, char(10))];
    % Write the updated script back to the file
    fid = fopen(scriptFilePath, 'w');
    fwrite(fid, updatedScript, 'char');
catch
    lasterr
    copyfile(backupFilePath, scriptFilePath);
end
fclose(fid);
delete(backupFilePath);
end