function out = matlab_jsondecode_arrayfun_wrapper(func, array_in, varargin)
%MATLAB_JSONDECODE_ARRAYFUN_WRAPPER wraps around a nested array so that an
%arrayfun is applied to cells of structures and structure arrays alike. 
% From matlab\external\interfaces\json\jsondecode.m
%   Array, when elements are  | cell array
%    of different data types  |
%   --------------------------+------------------
%   Array of booleans         | logical array
%   --------------------------+------------------
%   Array of numbers          | double array
%   --------------------------+------------------
%   Array of strings          | cellstr 
%   --------------------------+------------------
%   Array of objects, when    | structure array
%    all objects have the     |
%    same set of names        |
if ~exist('array_in', 'var')
    out = [];
    return
end
if iscell(array_in)
    out = cellfun(func, array_in, varargin{:});
elseif isstruct(array_in)
    out = arrayfun(func, array_in, varargin{:});
end
end