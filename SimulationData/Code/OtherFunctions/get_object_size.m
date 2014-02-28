function [ total_size ] = get_object_size( object, varargin )
%Iterates over an object's properties and sums up their sizes to
%calculate the size of an object in memmory (in bytes).
%  May not account for the fact that some properties are not stored but
%  rather calculated when queried.  Varargin is used to pass on the
%  recursion depth of this function.  Do not supply any optional arguments.

max_depth=20; %To prevent infinite recursion which can occur if two
%objects have each other as properties or have some cyclical dependence

if ~isempty(varargin);
    depth=varargin{1}+1;
else
    depth=1;
end
if depth>max_depth
    msgIdent='get_object_size:max_depth_reached';
    msgString='Maximum recursion depth reached, there is likely ';
    msgString=[msgString,'a cyclical dependence'];
    error(msgIdent,msgString);
end

%Start checking different types
if isnumeric(object) || ischar(object) || islogical(object)
    %If its an array, just return the array size
    total_size=whos_size(object);
    
elseif iscell(object)
    %If its a cell array, sum the sizes of the entries
    total_size=0;
    jMax=length(object);
    for j=1:jMax
        total_size=total_size+get_object_size(object{j},depth);
    end
    
elseif isstruct(object)
    %The object is a struct; use the local function below
    total_size=get_struct_size(object,depth);
    
elseif isa(object,'function_handle')
    %The object is a function handle
    temp=functions(object);
    total_size=get_object_size(temp,depth);
    
elseif isobject(object)
    %Doing it this way includes size of private attributes
    warning('off','MATLAB:structOnObject'); %Supress warning
    temp=struct(object);
    warning('on','MATLAB:structOnObject');
    total_size=get_struct_size(temp,depth);
    
else
    %Encountered something we don't know how to deal with
    msgIdent='get_object_size:UnknownClass';
    msgString='Not sure how to get the size of object %s; ';
    msgString=[msgString,'using size returned by whos...'];
    warn(msgIdent,msgString,class(object));
end


end

function total_size = whos_size( object ) %#ok<INUSD>
%Uses the size given by whos
temp=whos('object');
total_size=temp.bytes;
end

function total_size = get_struct_size( structure, depth)
%Returns the size of a structure object
props=fieldnames(structure);
running_sum=0;
%Sum over properties
for j=1:length(props)
    current_prop=getfield(structure,char(props(j))); %#ok<GFLD>
    running_sum=running_sum+get_object_size(current_prop,depth);
end
total_size=running_sum;
end