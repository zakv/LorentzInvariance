function tobj = successful_run()

%ex)
%   successful = successful_run();
%
%   successful.run('2010'or'2011'or'all','right'or'left'or'all')
%   successful.eventTime('local'or'utc','2010'or'2011'or'a
%   ll','right'or'left'or'all')

oldDr = cd('../DataSets/');
data_obj = load('EventTimeData');
cd(oldDr);

run2011R = data_obj.run2011R;
local2011R = data_obj.st2011R;
utc2011R = data_obj.utc2011R;

run2010R = data_obj.run2010R;
local2010R = data_obj.st2010R;
utc2010R = data_obj.utc2010R;

run2010L = data_obj.run2010L;
local2010L = data_obj.st2010L;
utc2010L = data_obj.utc2010L;

tobj = public();

    function run = run(year,RorL)
        if strcmp(year,'2010') == 1 &&  strcmp(RorL,'left') == 1
            run = run2010L;
        elseif strcmp(year,'2010') == 1 && strcmp(RorL,'right') == 1
            run = run2010R;
        elseif strcmp(year,'2011') == 1 && strcmp(RorL,'right') == 1
            run = run2011R;
        elseif strcmp(year,'all') == 1 && strcmp(RorL,'right') == 1
            run = vertcat(run2011R, run2010R);
            run = sor(run);
        elseif strcmp(year,'all') == 1 && strcmp(RorL,'left') == 1
            run = run2010L;
        elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
            run = vertcat(run2010R,run2010L);
            run = sort(run);
        elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
            run = run2011R;
        elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
            run = vertcat(run2011R,run2010R, run2010L);
            run = sort(run);
        else
            disp('ERROR mistyped year or RorL');
        end
    end

    function eventTime = eventTime(timeType,year,RorL)
        if strcmp(timeType,'utc') == 1
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'left') == 1
                eventTime = utc2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'right') == 1
                eventTime = utc2010R;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'right') == 1
                eventTime = utc2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'right') == 1
                eventTime = vertcat(utc2011R, utc2010R);
                eventTime = sort(eventTime);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'left') == 1
                eventTime = utc2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                eventTime = vertcat(utc2010R,utc2010L);
                eventTime = sort(eventTime);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                eventTime = utc2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                eventTime = vertcat(utc2011R, utc2010R, utc2010L);
                eventTime = sort(eventTime);
            else
                disp('ERROR mistyped year or RorL');
            end
        elseif strcmp(timeType,'local') == 1
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'left') == 1
                eventTime = local2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'right') == 1
                eventTime = local2010R;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'right') == 1
                eventTime = local2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'right') == 1
                eventTime = vertcat(local2011R, local2010R);
                eventTime = sort(eventTime);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'left') == 1
                eventTime = local2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                eventTime = vertcat(local2010R,local2010L);
                eventTime = sort(eventTime);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                eventTime = local2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                eventTime = vertcat(local2011R, local2010R, local2010L);
                eventTime = sort(eventTime);
            else
                disp('ERROR mistyped year or RorL');
            end 
        end
    end

    function o = public()
        o = struct(...
            'run', @run,...
            'eventTime', @eventTime);
    end
end