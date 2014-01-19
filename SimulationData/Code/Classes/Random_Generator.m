classdef Random_Generator
    %Class for generating random numbers
    %   Might change a lot in the future if we decide to use a different
    %   random number generator
    
    properties
        seed %Generator seed
        stream %Random number stream
    end
    
    methods
        
        function self = Random_Generator()
            %Initializes the random generator instance
            self.seed=mod(int32((now-today)*1000*feature('getpid')),2^32);
            self.stream=RandStream('twister','Seed',self.seed);
            rand(100); %Generate 10,000 numbers to get it well randomized (hopefully)
        end
        
        function numbers = rand(self,n_numbers)
            %Returns a row vector with the given number of elements
            numbers=rand(self.stream,1,n_numbers);
        end
        
    end
    
end

