function out_path = update_ks_params_path(ksDir)
%The params.py file output by kilosort references the temp_wh.dat file (CAR
%and highpass filtered AP data) using absolute paths for python use and
%thus might be incorrect after data migration.
%UPDATE_KS_PARAMS_PATH assumes the relative path is unchanged and finds the
%AP data file.
py_filesep = '/';
params_file = fullfile(ksDir, 'params.py');
if ~isfile(params_file)
    error('%s not found.', params_file);
end
fid = fopen(params_file);
all_text = char(fread(fid))';
fclose(fid);
[dat_path_text, dat_path_split] = regexp(all_text, 'dat_path\s*=\s*\S*', 'match', 'split');
if ~isempty(dat_path_text)
    param_dat_path = strsplit(dat_path_text{1}, {'=', ' '});
    param_dat_path = param_dat_path{2};
else
    error('No valid params.py found in %s', ksDir);
end
ks_path_parts    = strsplit(ksDir, filesep);
param_path_parts = strsplit(param_dat_path, py_filesep);

ks_path_parts_match     = ismember(ks_path_parts, param_path_parts);
param_path_parts_match  = ismember(param_path_parts, ks_path_parts);
ks_path_parts_lead      = 1:find(ks_path_parts_match, 1, 'last');
param_path_parts_follow = (find(param_path_parts_match, 1, 'last') + 1):numel(param_path_parts);
out_path = strjoin([ks_path_parts(ks_path_parts_lead), param_path_parts(param_path_parts_follow)], py_filesep);
out_path = clean_quotation(out_path);
all_text_out = strjoin([dat_path_split(1), {'dat_path = '}, {out_path}, dat_path_split(2)], '');
fid = fopen(params_file, 'w');
fwrite(fid, all_text_out, 'char')
fclose(fid);
end
function str_out = clean_quotation(str_in)
str_in(str_in == '''') = [];
str_out = ['''', str_in, ''''];
end