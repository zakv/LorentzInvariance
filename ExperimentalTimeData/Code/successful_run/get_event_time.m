function A = get_event_time(run)
%Gets UTC of eventTime
%   Gets Event time (event time calculated by using MCP time or CsI time), if these times are not
%   available, gets Entry time as a replacement (but this is not Event Time)
%   output : [run time type]
%       run - same as input run
%       type = 1 for time_MCP
%              2 for time_CsI
%              3 for time_matt (accurate to a minute, max : 87.6 sec compare to time_csi)
%              4 for MCP time (accurate to a minute before 10/4/2011, four minutes from the day, max 4.04 minutes)

iMax = numel(run);
stTime = zeros(size(run)); 
type = zeros(size(run));
for i=1:iMax
    time_MCP = get_event_time_via_mcp(run(i));
    if time_MCP > 0
        stTime(i) = time_MCP;
        type(i) = 1;
    else
        time_CsI = get_event_time_via_csi(run(i));
        if time_CsI > 0
            stTime(i) = time_CsI;
            type(i) = 2;
        else
            time_matt = get_event_time_via_matt(run(i));
            if time_matt > 0 
                stTime(i) = time_matt;
                type(i) = 3;
            else
                MCPtime = get_mcp_time(run(i));
                if MCPtime > 0
                    stTime(i) = MCPtime;
                    type(i) = 4;
                end
            end
        end
    end
end
A = [run stTime type];
end