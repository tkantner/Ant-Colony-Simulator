function prob = determineProb(Beta)
%Given Beta, the function picks a random number between 0 and 1. If its
%greater than Beta the function returns a 0, indicating to not use the move
%with the most pheramone. Else it returns a 1, using the move with the most
%pheramone

if rand > Beta
    prob = 0;
else
    prob = 1;
end

end
