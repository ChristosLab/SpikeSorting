clear
zw_setpath
database2019_fname = 'Z:\Development_project_2019\VanderbiltDAQ\Database2019_copy\Dev_Project2019.accdb';
if isfile(database2019_fname)
    access_mdb = AccessDatabase_OLEDB(database2019_fname);
    database_table = get_access_mdb_table(access_mdb,[],{'Neuron'});
end
%%