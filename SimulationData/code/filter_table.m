function [ filtered_table ] = filter_table(in_table,varargin)
%Returns a filtered table in which only rows where column_name==value are
%included
%   Sort of like SQL's "SELECT * FROM in_table WHERE column_name==value".
%   You specify filters by giving argument pairs of column_name and value.
%   For example, to get a table containing all the rows of Charman_table in
%   which the period was 'year' and the algorithm was 'Charman II',
%   execture the following command:
%   >> filter_table(Charman_table,'period','year','algorithm','Charman II')

nVarargs=length(varargin);
if mod(nVarargs,2)~=0
    msgIdent='filter_table:nVarargs';
    msgString='Each filter must a value pair of column_name and value';
    error(msgIdent,msgString);
end

filtered_table=in_table;
nPairs=nVarargs/2;
for j=1:nPairs
    column_name=varargin{2*j-1};
    value=varargin{2*j};
    row_logical=filtered_table{:,{column_name}}==value;
    filtered_table=filtered_table(row_logical,:);
end
end

