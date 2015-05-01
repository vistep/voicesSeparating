classdef Source
    % A sound source node
    %   Detailed explanation goes here
    
    properties
        index_list
        itd_list
    end 
   
    methods
        function obj = Source(index,itd)
            obj.index_list = index;
            obj.itd_list = itd;
        end
        
        function obj = Add(obj,index,itd)
            obj.index_list = [obj.index_list,index];
            obj.itd_list = [obj.itd_list,itd];
        end
        
        function num = getNum(obj)
            num = length(obj.itd_list);
        end
        
        function me = getMean(obj)
            me = mean(obj.itd_list);
        end
    end
           
end

