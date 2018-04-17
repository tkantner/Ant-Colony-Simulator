%Housekeeping
clear all;
clc;
close all;
rng('shuffle');

%Set Constants
num_rows = 10; %Rows
num_cols = 10; %Columns
N = 150; %Number of ants
goal = 65; %Goal Node
steps = 100; %Number of timesteps
B = .8; %Beta
lam = .1;%lambda
del = .4; %Delta
startPos = 1; %Start Position
nodes2Remove = 10; %How many random nodes we want to remove

%Create a grid and ant colony
grid = initGrid(num_rows, num_cols);
ants(1:N) = struct('pos', startPos, 'hist', zeros(1, steps), 'dir', 1, 'histSize', 0);
totalNumAnts = zeros(1, length(grid)); %Total ants who have touched that position


%Remove some nodes if we want to
if nodes2Remove > 0
goodSet = 0; %Check to make sure its good
removedNodes = zeros(1, nodes2Remove);
while goodSet == 0
    goodSet = 1;

    for k = 1:nodes2Remove
        x = randi([1,length(grid)]); %Pick some random Nodes
        while x == goal || x == startPos %Makes sure its not start or finish
            x = randi([1,length(grid)]);
        end
        removedNodes(k) = x; %add to vector
    end

    for k = 1:length(grid)
        for i = 1:length(removedNodes)
        grid(k).conn(grid(k).conn == removedNodes(i)) = []; %Remove them as neighbors
        end
        if length(grid(k).conn) < 2 %Check to make sure the combination will work
            goodSet = 0;
            grid = initGrid(num_rows, num_cols); %Recreate the grid
            break;
        end
    end

   
end

%Remove all the connections for the gplot
for k = 1:length(removedNodes)
    for i = length(grid(removedNodes(k)).conn):-1:1
        grid(removedNodes(k)).conn(i) = [];
    end
end


end



%Gplot stuff
xy = zeros(length(grid), 2);
A = zeros(length(grid), length(grid));
%Create xy matrix
for k = 1:length(grid)
    xy(k,1) = grid(k).x;
    xy(k,2) = grid(k).y;
end
%Create A matrix
for k = 1: length(grid)
    for j = 1: length(grid)
        for i = 1: length(grid(k).conn)
        if grid(k).conn(i) == j
            A(k,j) = 1;
            break;
        else
            A(k,j) = 0;
        end
        end
    end
end


grid(startPos).numAnts = N; %Set the number of ants
for t = 1:steps
    
    for i = 1:N %Loop through ants
        
        if ants(i).dir == 1 %Only in foraging mode
        ants(i).histSize = ants(i).histSize + 1; %Increment history size
        ants(i).hist(ants(i).histSize) = ants(i).pos; %Update history vector
        end
        
        grid(ants(i).pos).numAnts = grid(ants(i).pos).numAnts - 1; %Remove ant from that count
        ants(i).pos = determineNextPos(ants(i), goal, grid, B); %Find new Position
        grid(ants(i).pos).numAnts = grid(ants(i).pos).numAnts + 1; %Add ant to that count
        
        if ants(i).dir == 0 || ants(i).pos == goal %Drop some pheramone 
            grid(ants(i).pos).ph = grid(ants(i).pos).ph + 1;
        end
        
        if ants(i).pos == goal %If its the goal, change to returning
            ants(i).dir = 0;
        elseif ants(i).pos == startPos %If the ant returns home switch to foraging
            ants(i).dir = 1;
            ants(i).hist(ants(i).histSize) = 0;  %Remove from history and decrement size
            ants(i).histSize = ants(i).histSize - 1;
        elseif ants(i).dir == 0
            ants(i).hist(ants(i).histSize) = 0;  %Remove from history and decrement size
            ants(i).histSize = ants(i).histSize - 1;
        end
         
    end
   
  
    for k = 1:length(grid) %Loop through and decay pheramones
        grid(k).ph = decayPh(grid(k), lam, del);
    end
    
    for k = 1:length(grid)
        totalNumAnts(k) = totalNumAnts(k) + grid(k).numAnts;
    end
    
    % Dynamic Simulation Plotting
    clf('reset');
    gplot(A, xy);
    hold on;
    axis([(grid(1).x - 1) (grid(length(grid)).x + 1) (grid(1).y - 1) (grid(length(grid)).y + 1)]);
    title(sprintf('%i Ant Colony Progress: %i/%i',N, t, steps)); 
    for k = 1:length(grid)
        
        
        %Plot the removed nodes
        if nodes2Remove > 0
        yes = 0;
        for i = 1:length(removedNodes)
            if k == removedNodes(i)
                yes = 1;
                break;
            end
        end
        
        if yes == 1 %If its removed, continue
            continue;
        end
        end
        
        if k == goal %Plot the goal node
            plot(grid(k).x, grid(k).y, 'p', 'MarkerSize', 15, 'MarkerFaceColor', 'y');
            text(grid(k).x, grid(k).y, sprintf('%i Goal', grid(k).numAnts), 'HorizontalAlignment', 'center');
        elseif k == startPos %Plot the start
            plot(grid(k).x, grid(k).y, '^', 'MarkerSize', 15, 'MarkerFaceColor', 'y');
            text(grid(k).x, grid(k).y, sprintf('%i Start', grid(k).numAnts), 'HorizontalAlignment', 'center');
        elseif grid(k).numAnts > 0 && grid(k).numAnts <= 3   %The other nodes with ants
            plot(grid(k).x, grid(k).y, 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'green');
            text(grid(k).x, grid(k).y, sprintf('%i', grid(k).numAnts), 'HorizontalAlignment', 'center');
        elseif grid(k).numAnts > 3 && grid(k).numAnts <= 15
            plot(grid(k).x, grid(k).y, 'o', 'MarkerSize', grid(k).numAnts, 'MarkerFaceColor', 'green');
            text(grid(k).x, grid(k).y, sprintf('%i', grid(k).numAnts), 'HorizontalAlignment', 'center');
        elseif grid(k).numAnts > 15
             plot(grid(k).x, grid(k).y, 'o', 'MarkerSize', 15, 'MarkerFaceColor', 'green');
             text(grid(k).x, grid(k).y, sprintf('%i', grid(k).numAnts), 'HorizontalAlignment', 'center');
        else %Nodes without ants
           plot(grid(k).x, grid(k).y, 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'c');
        end

    end
    drawnow;
    hold off;
    
    
end

%Final Plot
clf('reset');
gplot(A, xy);
axis([(grid(1).x - 1) (grid(length(grid)).x + 1) (grid(1).y - 1) (grid(length(grid)).y + 1)]);
hold on;
for k = 1:length(grid)
    
    if k == goal %Plot the goal node
        plot(grid(k).x, grid(k).y, 'p', 'MarkerSize', 15, 'MarkerFaceColor', 'y');
        text(grid(k).x, grid(k).y, sprintf('Goal: %i', totalNumAnts(k)), 'HorizontalAlignment', 'center');
    elseif k == startPos %Plot the start
        plot(grid(k).x, grid(k).y, '^', 'MarkerSize', 15, 'MarkerFaceColor', 'y');
        text(grid(k).x, grid(k).y, sprintf('Start: %i', totalNumAnts(k)), 'HorizontalAlignment', 'center');
    elseif totalNumAnts(k) > 15 %The other nodes
        plot(grid(k).x, grid(k).y, 'o', 'MarkerSize', 15, 'MarkerFaceColor', 'green');
        text(grid(k).x, grid(k).y, sprintf('%i', totalNumAnts(k)), 'HorizontalAlignment', 'center');
    else %The other nodes
        text(grid(k).x, grid(k).y, sprintf('%i', totalNumAnts(k)), 'HorizontalAlignment', 'center');
    end
    
    title('Total Number of Visiting Ants During the Simulation');
end
hold off;

