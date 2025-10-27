function config = load_config(config_file)
% LOAD_CONFIG Load configuration from YAML file
%
% Syntax:
%   config = load_config()
%   config = load_config(config_file)
%
% Description:
%   Loads the SimEIT configuration from a YAML file and returns it as a
%   struct. If no file is specified, looks for 'config.yaml' in the
%   project root directory.
%
% Inputs:
%   config_file - (Optional) Path to the YAML configuration file
%
% Outputs:
%   config - Struct containing all configuration parameters
%
% Example:
%   config = load_config();
%   electrodes_num = config.model.electrodes_num;
%
% Author: SimEIT Team
% Date: 2025

    if nargin < 1
        % Default config file location
        try
            dir_function = mfilename('fullpath');
            [dir_function, ~, ~] = fileparts(dir_function);
            config_file = fullfile(dir_function, '..', 'config.yaml');
        catch
            config_file = 'config.yaml';
        end
    end
    
    % Check if file exists
    if ~exist(config_file, 'file')
        error('Config file not found: %s', config_file);
    end
    
    % Try to use YAML library if available
    try
        % Try using yaml library (if installed)
        config = yaml.ReadYaml(config_file);
    catch
        % Fallback: Read file manually
        warning('YAML library not found. Using basic parser. Install yaml library for full support.');
        config = parse_yaml_basic(config_file);
    end
    
    % Apply defaults for null values
    if isfield(config.dataset, 'patch_number') && isempty(config.dataset.patch_number)
        config.dataset.patch_number = [];
    end
    
    if isfield(config.parallel, 'workers') && isempty(config.parallel.workers)
        config.parallel.workers = [];
    end
    
end

function config = parse_yaml_basic(filename)
    % Basic YAML parser for simple key-value pairs
    % This is a simplified parser and may not handle all YAML features
    
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
    
    config = struct();
    current_section = '';
    current_subsection = '';
    last_key = ''; % tracks last key at current_section level for list items
    
    try
        while ~feof(fid)
            line = fgetl(fid);
            
            % Skip comments and empty lines
            if isempty(line) || startsWith(strtrim(line), '#')
                continue;
            end
            
            % Remove inline comments
            comment_pos = strfind(line, '#');
            if ~isempty(comment_pos)
                line = line(1:comment_pos(1)-1);
            end
            
            % Compute indentation BEFORE trimming (count leading spaces)
            raw_line = strip(line,'right');
            indent = length(raw_line) - length(strtrim(raw_line));

            % Now trim for content parsing
            line = strtrim(raw_line);
            if isempty(line)
                continue;
            end
            
            % Check for section (main key with colon at end)
            if endsWith(line, ':') && indent == 0
                current_section = matlab.lang.makeValidName(strrep(line, ':', ''));
                config.(current_section) = struct();
                current_subsection = '';
                last_key = '';
            elseif contains(line, ':') && indent == 2 && endsWith(line, ':')
                % Subsection
                current_subsection = matlab.lang.makeValidName(strtrim(strrep(line, ':', '')));
                if ~isempty(current_section)
                    config.(current_section).(current_subsection) = struct();
                end
            elseif contains(line, ':')
                % Key-value pair
                % Split at the first colon only
                parts = regexp(line, ':\s*', 'split', 'once');
                if numel(parts) == 2
                    key = matlab.lang.makeValidName(strtrim(parts{1}));
                    value_str = strtrim(parts{2});
                    value = parse_value(value_str);
                    
                    if indent >= 4 && ~isempty(current_subsection) && ~isempty(current_section)
                        config.(current_section).(current_subsection).(key) = value;
                    elseif indent == 2 && ~isempty(current_section)
                        config.(current_section).(key) = value;
                        last_key = key; % remember last key for potential following list items
                    end
                end
            elseif startsWith(line, '-')
                % List item
                value_str = strtrim(line(2:end));
                value = parse_value(value_str);
                
                if indent >= 4 && ~isempty(current_subsection) && ~isempty(current_section)
                    if ~isfield(config.(current_section), current_subsection) || ...
                       ~iscell(config.(current_section).(current_subsection))
                        config.(current_section).(current_subsection) = {};
                    end
                    config.(current_section).(current_subsection){end+1} = value;
                elseif indent == 2 && ~isempty(current_section)
                    % Append to the most recent key under current_section
                    if ~isempty(last_key) && isfield(config.(current_section), last_key)
                        if ~iscell(config.(current_section).(last_key))
                            config.(current_section).(last_key) = {};
                        end
                        config.(current_section).(last_key){end+1} = value;
                    else
                        % Fallback to previous heuristic if last_key unknown
                        keys_in_section = fieldnames(config.(current_section));
                        if ~isempty(keys_in_section)
                            k = keys_in_section{end};
                            if ~iscell(config.(current_section).(k))
                                config.(current_section).(k) = {};
                            end
                            config.(current_section).(k){end+1} = value;
                            last_key = k;
                        end
                    end
                end
            end
        end
        fclose(fid);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
end

function value = parse_value(value_str)
    % Parse value from string
    value_str = strtrim(value_str);
    
    % Check for null
    if strcmpi(value_str, 'null') || isempty(value_str)
        value = [];
        return;
    end
    
    % Check for boolean
    if strcmpi(value_str, 'true')
        value = true;
        return;
    elseif strcmpi(value_str, 'false')
        value = false;
        return;
    end
    
    % Check for string (quoted)
    if (startsWith(value_str, '''') && endsWith(value_str, '''')) || ...
       (startsWith(value_str, '"') && endsWith(value_str, '"'))
        value = value_str(2:end-1);
        return;
    end
    
    % Check for array
    if startsWith(value_str, '[') && endsWith(value_str, ']')
        array_str = strtrim(value_str(2:end-1));
        if isempty(array_str)
            value = [];
            return;
        end
        % Split on commas, allowing spaces around
        items = regexp(array_str, '\s*,\s*', 'split');
        parsed = cellfun(@(x) parse_value(x), items, 'UniformOutput', false);
        % If all items are numeric scalars, convert to a numeric array
        is_num = cellfun(@(x) isnumeric(x) && isscalar(x) && ~isnan(x), parsed);
        if all(is_num)
            value = cell2mat(parsed(:))';
        else
            value = parsed;
        end
        return;
    end
    
    % Try to parse as number
    num_val = str2double(value_str);
    if ~isnan(num_val)
        value = num_val;
        return;
    end
    
    % Default: return as string
    value = value_str;
end