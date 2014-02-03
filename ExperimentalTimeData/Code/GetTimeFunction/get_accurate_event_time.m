function A = get_accurate_event_time(run)
%Gets UTC of eventTime
%   Gets Event time (time_MCP or time_CsI), if these times are not
%   available, skips the run (the length of imput function and output
%   function is different)
%   output : [run time type]
%   run - different from input run
%   type = 1 for time_MCP
%          2 for time_CsI

iMax = numel(run);
stTime = zeros(size(run)); 
type = zeros(size(run));
run_new = zeros(size(run));
k = 1;
for i=1:iMax
    time_MCP = get_event_time_via_mcp(run(i));
    if time_MCP > 0
        stTime(k) = time_MCP;
        type(k) = 1;
        run_new(k) = run(i);
        k = k+1;
    else
        time_CsI = get_event_time_via_csi(run(i));
        if time_CsI > 0
            stTime(k) = time_CsI;
            type(k) = 2;
            run_new(k) = run(i);
            k = k+1;
        end
    end
end
A = [run_new stTime type];
A = A(1:k-1,:);
end