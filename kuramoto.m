
% Parameters
N = 68; % n of nodes
p = 0.1; % p of edge 
K = 1; % coupling strength

% Erdős-Rényi graph
adjMatrix = rand(N) < p; % adjacency matrix
adjMatrix = triu(adjMatrix, 1); % avoid double connectionsredudancy
adjMatrix = adjMatrix + adjMatrix'; % Make it symmetric

% Kuramoto model 
omega = rand(N, 1) * 2 * pi; %  frequencies
theta = rand(N, 1) * 2 * pi; % Initial phases

% Simulation parameters
dt = 0.01; % Time step
T = 10; % Total time
steps = T / dt; % Number of time steps

% Time evolution of phases
for t = 1:steps
    % Update phases
    theta = theta + dt * (omega + (K/N) * (adjMatrix * sin(theta - theta')));
end

% Visualization
figure;
g = graph(adjMatrix);
plot(g, 'Layout', 'layered', 'NodeLabel', {}, 'EdgeColor', 'k');
title('Erdős-Rényi Network with Kuramoto Oscillators');
xlabel('Node Index');
ylabel('Node Index');

% Plot final phases
figure;
scatter(1:N, theta, 50, 'filled');
xlim([1 N]);
xlabel('Node Index');
ylabel('Phase (radians)');
title('Final Phases of Kuramoto Oscillators');
