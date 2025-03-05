function jitterplot(data, groups, options)
% Purpose: This function is an alternative to boxplots for categorized
% numeric data. 
%
%
% Required Inputs:
%   data (1,:) numeric expression data for n samples.
%   groups (1,:) grouping variable for n samples. Cell array of character data.
% 
%
% Optional Inputs: 
%   colors (:,3) numeric matrix of type double. Each row contains an RGB
%          triplet. 
%   PlotTitle ('string') title of the plot
%   xlabel ('string') x-axis label
%   ylabel ('string') y-axis label
%   jitter (1,1) numeric value representing maximum amount of jitter
%          (offset between points)
%   colorgrp (1,:) 2nd grouping variable for n samples. Determines the colour
%            of the plotted points and maps to the legend
%   showMedianValues (boolean) plot median values for each 'groups'
%                    category
%   showLegend (boolean) plot a legend
%   sortOrder (1,:) cell array of character vectors. Force an order of
%             categories in plot. Must have each category given once.
%
%
% NOTE: If the 'groups' or 'options.colorgrp' variable is a cell array of numeric
% vectors (ex. batch numbers), it can be converted to a cell array of character 
% vectors using: CELL_ARRAY_OF_CHARS = cellfun(@num2str, CELL_ARRAY_OF_NUMS, 'UniformOutput', false)
%
%
% Outputs:
%   A very nice jitter plot :)
%
% 
% Author: Simona Damiani
% Date: February 11th, 2025


%% Check input arguments
arguments
    data (1,:) {mustBeNumeric}
    groups (1,:) cell 
    options.colors (:,3) {mustBeNumeric}
    options.PlotTitle string = ''
    options.xlabel string = ''
    options.ylabel string = ''
    options.jitter (1,1) double = 0.5
    options.colorgrp (1,:) cell = []
    options.showMedianValues = true
    options.showLegend = false
    options.sortOrder cell
end

%% Sort data if sort order is provided
if ~isempty(options.sortOrder)
    [~, sort_idx] = sort(cellfun(@(x) find(strcmp(options.sortOrder, x)), groups));
    data = data(:, sort_idx); % Reorder the entire cell array with 'sort_idx'
    groups = groups(:,sort_idx);
end

% Also sort colorgrp if provided
if ~isempty(options.sortOrder) && ~isempty(options.colorgrp)
    options.colorgrp = options.colorgrp(:, sort_idx); % Reorder the entire cell array with 'sort_idx'
end

%% Create Jitter Plot
% Convert grouping data to numeric for indexing colours
if ~isempty(options.colorgrp) 
    num_groups = num2cell(grp2idx(options.colorgrp)); % Colour group option - cell array of character data
    char_groups = unique(options.colorgrp, 'stable'); % Unique groups for legend
else 
    num_groups = num2cell(grp2idx(groups)); % Colour group defaults to x-axis grouping
    char_groups = unique(groups, 'stable'); % Unique groups for legend
end

% Create colour matrix if colours provided (or default to blue if not)
if isempty(options.colors)
    colmat = 'blue'; % defaults to blue for all points if no colours are inputted
else
    % Initialize array for RGB triplets
    colmat = zeros([size(data,2),3]);
    % Generate RGB triplet matrix
    for i = 1:size(data,2)
        colmat(i,:) = options.colors(cell2mat(num_groups(i)), :);
    end
end

% open figure window
figure, 
% Plot using swarmchart - disabled automatic sorting with categorical()
s = swarmchart(categorical(groups, unique(groups, 'stable')), data, 40, colmat, "filled"); % Specify numeric data, grouping data, marker_size, colours & filled markers
% Control jitter width if provided
s.XJitterWidth = options.jitter; 
% retain current plot when adding new plots
hold on  
% Disable swarmchart from automatically plotting onto the legend
legend('AutoUpdate', 'off');


%% Plot Aesthetics
% Add plot title if provided
if ~isempty(options.PlotTitle)
    title(options.PlotTitle, 'FontSize',16, 'FontName', 'Helvetica','Interpreter','none');
end

% Add x axis label if provided
if ~isempty(options.xlabel)
    xlabel(options.xlabel, 'FontSize',14, 'FontName', 'Helvetica','Interpreter','none');
end

% Add y axis label if provided
if ~isempty(options.ylabel)
    ylabel(options.ylabel, 'FontSize',14, 'FontName', 'Helvetica','Interpreter','none');
end

%% Create legend
if options.showLegend && ~isempty(options.colors)
    
    % Pre-allocate array for graphics objects
    h = gobjects(size(char_groups,2),1);
    
    % Create invisible scatter plot to build legend
    for i = 1:size(char_groups,2)
        h(i) = scatter(NaN, NaN, 50, options.colors(i,:), 'filled'); 
    end

    % Add legend to plot
    legend(h,char_groups);

else
    legend off
end

%% Plot median values for each group
if options.showMedianValues
   
    % Compute median for each group
    unique_groups = unique(groups, 'stable');
    medians = cellfun(@(g) median(data(strcmp(groups, g))), unique_groups);
    
    % Find x-axis positions for each group
    x_locations = 1:length(unique_groups);  
    
    % Plot median value lines
    for i = 1:length(unique_groups)
        line([x_locations(i) - 0.3, x_locations(i) + 0.3], ... % x-range of the line
             [medians(i), medians(i)], ... % y-value of line (median)
             'Color', 'k', 'LineWidth', 2); % Line aesthetics
    end
end

% Prevent additional plotting onto jitterplot
hold off
end