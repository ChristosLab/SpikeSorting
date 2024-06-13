% July-22-2023 Added column names to query output. -Zhengyang Wang
% ACCESSDATABASE_OLEDB Provides an OLEDB connection to an access database
%
%     obj = AccessDatabase_OLEDB(dbpath, provider)
%
%         dbpath: Relative or absolute path to the mdb or accdb file
%
%         provider: The OLEDB provider.
%             * 'Microsoft.ACE.OLEDB.12.0': Suitable for newer systems
%               'Microsoft.Jet.OLEDB.4.0': Use for older systems
%
%             * = default
%
%
% Copyright (c) 2012 Gordon MacKenzie-Leigh
%
% This work is made available free of charge to educate, inform and
% inspire.  You may make use of this work, copy it, and distribute it
% unchanged, provided you keep this copyright notice intact.  You may make
% derivative works (by modifiying this work or incorporating all or parts
% of this work into your own work) provided you acknowledge the original 
% author(s) where appropriate.  You may include this work as part of a 
% commercial product, provided that this work or similarly-licensed work  
% does not form a substantial part of that product.  THIS SOFTWARE IS  
% PROVIDED "AS-IS" AND NO WARRANTY OR GUARANTEES ARE PROVIDED OR IMPLIED.
% USE OF THIS WORK IS ENTIRELY AT YOUR OWN RISK.

classdef AccessDatabase_OLEDB < handle    
    properties (SetAccess = private, GetAccess = private)
        connection
    end
    
    methods
        
        function obj = AccessDatabase_OLEDB(dbpath, provider)
            % ACCESSDATABASE_OLEDB Creates a new connection
            %
            %     dbpath: Relative or absolute path to the mdb or accdb file
            %
            %     provider: The OLEDB provider.
            %        * 'Microsoft.ACE.OLEDB.12.0': Suitable for newer systems
            %          'Microsoft.Jet.OLEDB.4.0': Use for older systems
            %
            %        * = default
            %
            
            % defaults
            if nargin == 1
                provider = 'Microsoft.ACE.OLEDB.12.0';
            end
            
            % expand the dbpath from relative reference and check it exists.
%             dbpath = which(dbpath);
%             
%             if strcmp(dbpath, '')
%                 error('AccessDatabase_OLEDB: dbpath: Database path not found');
%             end
            
            obj.connection = actxserver('ADODB.Connection');
            obj.connection.Open(['Provider=' provider ';Data Source=' dbpath]);
        end
        
        
        function data = query(obj, sql)
            % QUERY Runs a query on the database connection and returns the data
            %
            %     data = connection.query(sql)
            %
            %        sql: the sql code to run on the connection
            %
            
            try
                rs = actxserver('ADODB.RecordSet');
                rs.Open(sql, obj.connection);
                
                if rs.State == 1
                    % recordset is open
                    data = rs.GetRows';
                    col_n = size(data, 2);
                    varnames = cell(1, col_n);
                    for i_col = 1:col_n
                        varnames{i_col} = rs.Fields.Item(i_col - 1).name;
                    end
                    data = cell2table(data, "VariableNames", varnames);
                    rs.Close;
                else
                    data = [];
                end
                rs.delete;
            catch e
                warning('AccessDatabase_OLEDB:errorHint', ...
                    ['Error caused by query: "' sql '"']);
                rethrow(e);
            end
        end
        
        
        function delete(obj)
            obj.connection.Close;
            obj.connection.delete;
        end        
    end
    
end