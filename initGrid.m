function grid = initGrid(numRows, numCols)
% INITGRID intializes the node locations on the x-y grid, sets the initial
% amount of pheromone at each location, and establishes each node's
% connectivity to its neighbors.
%
% The nodes are arranged in a (numRows x numCols) staggered distribution
% and currently connected with an equilateral triangular lattice.

% Calculate the total number of nodes
numNodes = numRows*numCols;

% Preallocate the structured variable array
grid(1:numNodes) = struct('ID', [], 'x', [], 'y', [], 'conn', [], 'ph', 0, 'numAnts', 0);

% Set spacing in the x and y direction (set for equilateral triangle)
ySpacing = 1;
xSpacing = ySpacing/2*sqrt(3);

count = 0;

% Calculate the x and y position of each node
for col = 1:numCols
    for row = 1:numRows
        count = count + 1;
        grid(count).ID = count;
        grid(count).x = xSpacing*(col-1);
        grid(count).y = ySpacing*(row-1 + 0.5*mod(col, 2));
    end
end

% Find all the neighbors of node k amongst nodes j and store in 'conn'
for k = 1:numNodes
    for j = 1:numNodes
        if j ~= k
            % Calculate the separation between the two nodes
            dx = grid(k).x - grid(j).x;
            dy = grid(k).y - grid(j).y;
            dist = sqrt(dx^2 + dy^2);
            
            % If separation is less than some threshold, add the connection
            if dist < 1.2*ySpacing
                grid(k).conn = [grid(k).conn, j];
            end
        end
    end
end
