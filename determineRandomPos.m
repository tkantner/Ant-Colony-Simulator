function pos = determineRandomPos(neighbors)
%Determines a random position for the ant to move to, excluding the last point that the ant was at.

pos = neighbors(randi([1,length(neighbors)]));  %Pick a random element and return Pos

end
