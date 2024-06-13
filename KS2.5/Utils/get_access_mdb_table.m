function tbl_out = get_access_mdb_table (access_mdb, select, from, varargin)
if isempty(from)
    from = {'Neuron'};
end
if isempty(select)
    select = {'*'};
end
select_clause = 'SELECT ';
from_clause = 'FROM ';
select_clause = [select_clause, strjoin(select, ',')];
from_clause = [from_clause, strjoin(from, ',')];
sql_query = [select_clause, from_clause];
tbl_out = access_mdb.query(sql_query); 
end