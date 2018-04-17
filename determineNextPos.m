function NewPos = determineNextPos(ant, goal, grid, Beta)
%Given the ant and goal, determines the next position that the ant should move to

if ant.dir == 1  %If in foraging mode
    
    
    neighbors = grid(ant.pos).conn; %Create neighbors
    if ant.histSize > 1
    neighbors(neighbors == ant.hist(ant.histSize - 1)) = [];
    end

    
    for k = 1:length(neighbors)  %Loop through connections to look for goal
        
        if neighbors(k) == goal  %Case 1: Next one is the goal
            NewPos = neighbors(k); %Set the new position to the goal
            return; %return so it doesnt get overwritten
        end
    end
    
    neighborsPh = [grid(neighbors).ph]; %Create a vector of ph
    [maxValue, maxIndex] = max(neighborsPh); %Find the max value and index
    
     if maxValue > 0 %if there is a position with pheramone
        
        if determineProb(Beta) == 1
           NewPos = neighbors(maxIndex);
        else %otherwise determine a random position
           NewPos = determineRandomPos(neighbors);
        end
        
     else %Otherwise there is no pheramone and we pick a random
            NewPos = determineRandomPos(neighbors);
     end
    
 
    
else % Ant is in returning mode
  
    NewPos = ant.hist(ant.histSize); %New Position is last one
    
end

end
