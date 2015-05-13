classdef Pool<handle
    properties
        workers={};
        queue={};
    end
    methods
        function N=nw(self)
            % return number of workers
            N=length(self.workers);
        end
    end
end
