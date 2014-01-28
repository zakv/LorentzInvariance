classdef Random_Generator
    %Class for generating random numbers
    %   Might change a lot in the future if we decide to use a different
    %   random number generator
    
    properties
        seed %Generator seed
        stream %Random number stream
    end
    
    methods
        
        function self = Random_Generator(varargin)
            %Initializes the random generator instance.
            %  Can optionally specify the seed, which will get hashed
            %  before being used as the seed.
            if length(varargin)>=1
                self.seed=varargin{1};
            else
                self.seed=(10000*now-floor(now*10000))*10^9;
            end
            self.seed=self.hash_numeric(self.seed);
            self.stream=RandStream('twister','Seed',self.seed);
            rand(100); %Generate 10,000 numbers to get it well randomized (hopefully)
        end
        
        function numbers = rand(self,n_numbers)
            %Returns a column vector with the given number of elements
            numbers=rand(self.stream,n_numbers,1);
        end
        
    end
    
    methods (Static)
        
        function hash_value = hash_numeric(numeric)
            %Returns an unsigned 32bit integer as a hash of the input value
            %   Takes a subset of the SHA-256 Hash
            
            %Check input
            if isnumeric(numeric)==false
                msgIdent='Random_Generator:hash_value:NonNumericInput';
                msgString='Input must be a numeric value';
                error(msgIdent,msgString);
            end
            
            %Perform hash
            Engine = java.security.MessageDigest.getInstance('SHA-256');
            Engine.update(typecast(numeric, 'uint8'));
            Hash   = typecast(Engine.digest, 'uint32');
            hash_value=Hash(1); %Take subset of 256bit hash
        end
        
    end
    
end

