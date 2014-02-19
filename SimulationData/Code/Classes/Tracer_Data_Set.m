classdef Tracer_Data_Set < handle
    %Stores the data from one tracer run (one charge and one quip).
    
    properties (Constant)
        TRACER_DATA_DIR='../../TracerOutput';
        TRACER_REGEX='SimData_([pn])(\d+)[eE](\d+)([LR])';
    end
    
    
    properties (SetAccess=private)
        file_name %Name of file (without path)
        charge %Fractional charge given
        quip %direction, either 'left' or 'right'
        z_positions %z-positions of data
    end
    
    methods
        
        function self = Tracer_Data_Set(file_name)
            %Initializes the Tracer_Data_Set instance.  file_name should the
            %name of a file in the TracerOutput directory (without path).
            self.file_name=file_name;
            self.interpret_file_name(file_name);
            full_file_name=fullfile(Tracer_Data_Set.TRACER_DATA_DIR,file_name);
            self.z_positions=load_mat(full_file_name);
        end
        
    end
    
    methods (Hidden)
        
        function [] = interpret_file_name(self,file_name)
            %Parses the file name to set charge and quip
            
            match=regexp(file_name,Tracer_Data_Set.TRACER_REGEX,'tokens');
            match=match{1};
            if isempty(match)
                msgIdent='Tracer_Data_Set:interpret_file_name:NameError';
                msgString='Invalid file_name %s\nfile_name must be ';
                msgString=[msgString,'something like p4e8L'];
                error(msgIdent,msgString,file_name);
            end
            
            %Figure out charge
            sign_char=match{1};
            if sign_char=='n'
                sign=-1;
            elseif sign_char=='p'
                sign=1;
            end
            
            mantissa=str2double(match{2});
            exponent=str2double(match{3});
            self.charge=sign*mantissa*10^(-exponent);
            
            %Figure out quip direction
            quip_char=match{4};
            if quip_char=='L'
                self.quip='left';
            elseif quip_char=='R'
                self.quip='right';
            end
            
        end
        
    end
    
end

