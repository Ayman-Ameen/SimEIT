# Development Guide

This guide is for developers who want to extend or modify the SimEIT toolkit.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Code Organization](#code-organization)
3. [Data Flow](#data-flow)
4. [Adding New Features](#adding-new-features)
5. [Testing](#testing)
6. [Coding Standards](#coding-standards)
7. [Contributing](#contributing)

---

## Architecture Overview

### System Components

The SimEIT toolkit consists of several modular components:

```
┌─────────────────────────────────────────────────────────┐
│                   generate_dataset.m                     │
│                  (Main Entry Point)                      │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
┌──────────────┐ ┌─────────┐ ┌──────────────┐
│ Data         │ │Generate │ │ Traditional  │
│ Functions    │ │Functions│ │ Methods      │
└──────────────┘ └─────────┘ └──────────────┘
        │            │            │
        └────────────┼────────────┘
                     │
                     ▼
              ┌─────────────┐
              │   EIDORS    │
              │  (External) │
              └─────────────┘
```

### Key Design Principles

1. **Modularity**: Each directory contains related functions
2. **Separation of Concerns**: Data generation, visualization, and analysis are separate
3. **EIDORS Integration**: Uses EIDORS as the finite element solver
4. **Batch Processing**: Supports large datasets through patch-based generation

---

## Code Organization

### Directory Structure

```
SimEIT_internal/
├── data_functions/          # Dataset creation and manipulation
│   ├── create_csv_dataset.m
│   ├── features_parameters.m
│   ├── load_config.m
│   └── ...
├── generate_functions/      # Forward model and solver
│   ├── create_model.m
│   ├── generate_patch.m
│   ├── forward_solver_for_one_sample.m
│   └── ...
├── traditional_methods/     # Inverse problem solvers
│   ├── traditional_methods.m
│   ├── get_solver.m
│   └── ...
├── plots/                   # Visualization utilities
│   ├── show_fem_dataset.m
│   ├── visualize_dataset_and_details.m
│   └── ...
├── combine_and_down_scale/  # Post-processing
│   ├── combine_and_down_scale_dataset.m
│   └── downscale_patch.m
├── eidors/                  # EIDORS library (external)
├── docs/                    # Documentation
└── generate_dataset.m       # Main script
```

### Module Responsibilities

#### data_functions/
- **Purpose**: Generate synthetic metadata (shapes, conductivities)
- **Key files**:
  - `create_csv_dataset.m`: Main dataset metadata generator
  - `features_parameters.m`: Shape sampling and validation
  - `load_config.m`: Configuration file parser

#### generate_functions/
- **Purpose**: Create FEM models and solve forward problems
- **Key files**:
  - `create_model.m`: Build EIDORS forward model
  - `generate_patch.m`: Generate samples from metadata
  - `forward_solver_for_one_sample.m`: Compute voltages

#### traditional_methods/
- **Purpose**: Benchmark reconstruction algorithms
- **Key files**:
  - `get_solver.m`: Configure inverse solvers
  - `traditional_methods.m`: Evaluation script

---

## Data Flow

### Forward Problem Pipeline

```
1. Configuration
   config.yaml → load_config() → config struct

2. Model Creation
   config → create_model() → EIDORS fwd_model

3. Metadata Generation
   config → create_csv_dataset() → shape descriptors

4. Shape Validation
   descriptors → features_parameters() → valid features

5. Forward Solve
   features + fwd_model → forward_solver_for_one_sample() → voltages

6. Storage
   images + voltages → save_hdf5() → dataset.h5
```

### Data Structures

#### Configuration Struct
```matlab
config = struct(
    'general', struct('mode', 'simulation', 'description', '...'),
    'model', struct('electrodes_num', 16, 'resolution', 256),
    'solver', struct('method_name', 'jacobian', ...),
    'dataset', struct('number_of_samples', 1000, ...)
)
```

#### EIDORS Forward Model
```matlab
fwd_model = struct(
    'nodes', [N x 2],           % Node coordinates
    'elems', [Ne x 3],          % Element connectivity
    'electrode', {1xNe struct}, % Electrode definitions
    'stimulation', {1xNs struct}, % Stimulation patterns
    ...
)
```

#### Dataset Table (from create_csv_dataset)
```matlab
data = table(
    index1,              % [N x 1] Sample indices
    number_of_objects,   % [N x 1] Objects per sample
    type,                % [N x 4] cell array of shape types
    conductivity,        % [N x 4] Conductivity values
    features,            % [N x 4] cell array of feature vectors
    coverage_area        % [N x 1] Coverage fraction
)
```

---

## Adding New Features

### Adding a New Shape Type

**Example**: Adding a polygon shape

1. **Modify `create_csv_dataset.m`**:
```matlab
% Add 'polygon' to shape types
type_all_init = {'circle', 'ellipse', 'rectangle', 'triangle', 'polygon'};
```

2. **Update `features_parameters.m`**:
```matlab
% Add polygon generation logic
case 'polygon'
    n_sides = randi([5, 8]);  % 5-8 sided polygon
    angles = sort(rand(1, n_sides) * 2*pi);
    radii = 0.1 + 0.3*rand(1, n_sides);
    % ... compute vertices
    features_rand = [center_x, center_y, angles(:)', radii(:)'];
```

3. **Update `object2str.m`**:
```matlab
case 'polygon'
    % Convert polygon features to EIDORS string equation
    vertices = compute_polygon_vertices(origin, size_or_theta);
    object_str = create_polygon_constraint(vertices);
```

4. **Test**:
```matlab
% Generate small test dataset
config.dataset.number_of_samples = 10;
run generate_dataset.m
```

### Adding a New Solver Method

**Example**: Adding a custom reconstruction method

1. **Create solver function** in `traditional_methods/`:
```matlab
function img_out = my_custom_solver(inv_model, data1, data2)
% MY_CUSTOM_SOLVER Custom EIT reconstruction method
%   img_out = my_custom_solver(inv_model, data1, data2)
    
    % Get Jacobian
    J = calc_jacobian(inv_model.fwd_model);
    
    % Your algorithm here
    conductivity = my_algorithm(J, data1, data2);
    
    % Package output
    img_out = mk_image(inv_model.fwd_model, conductivity);
end
```

2. **Add to `get_solver.m`**:
```matlab
case 'my_custom_method'
    inverse_model.solve = @my_custom_solver;
    inverse_model.hyperparameter.value = 0.1;
    metadata.paper_s = {'Your Paper Reference'};
    metadata.website = {'Documentation URL'};
```

3. **Update `traditional_methods.m`**:
```matlab
methods_names = {'total_variation', 'my_custom_method'};
```

### Adding Configuration Parameters

1. **Update `config.yaml`**:
```yaml
solver:
  method_name: jacobian
  my_new_parameter: 42
```

2. **Modify `load_config.m`** to parse:
```matlab
% In the parsing section
if isfield(yaml.solver, 'my_new_parameter')
    config.solver.my_new_parameter = yaml.solver.my_new_parameter;
else
    config.solver.my_new_parameter = 42;  % Default
end
```

3. **Use in code**:
```matlab
my_value = config.solver.my_new_parameter;
```

---

## Testing

### Unit Testing

Create test scripts in each directory:

```matlab
% test_create_model.m
function test_create_model()
    resolution = 64;
    dimension = '2d';
    z_contact = 0.01;
    scale = [1, 1, 1];
    shape_function = 'unit_circle';
    coverage_ratio = 0.2;
    number_virtual_electrodes = 16;
    electrodes_number = 16;
    reinforcement_electrodes = 2;
    
    model = create_model(resolution, dimension, z_contact, scale, ...
        shape_function, coverage_ratio, number_virtual_electrodes, ...
        electrodes_number, reinforcement_electrodes);
    
    % Assertions
    assert(~isempty(model.nodes), 'Nodes should not be empty');
    assert(~isempty(model.elems), 'Elements should not be empty');
    assert(length(model.electrode) == electrodes_number, ...
        'Electrode count mismatch');
    
    disp('test_create_model: PASSED');
end
```

### Integration Testing

Use `test_dataset.m` to validate complete pipeline:

```matlab
% Test small dataset
electrodes_num = 16;
resolution = 64;
local_patch_size = 10;
patch_number_all = [0];

% Run validation
run generate_functions/test_dataset.m
```

### Regression Testing

1. Generate reference dataset with known configuration
2. Save checksums or sample statistics
3. Re-run after changes and compare

```matlab
% After generating test dataset
test_sample = h5read('dataset.h5', '/electrodes_16/image_256/image', [1,1,1], [1,256,256]);
reference_mean = mean(test_sample(:));
reference_std = std(test_sample(:));

% After code changes
new_sample = h5read('dataset.h5', '/electrodes_16/image_256/image', [1,1,1], [1,256,256]);
assert(abs(mean(new_sample(:)) - reference_mean) < 1e-6, 'Mean changed');
```

---

## Coding Standards

### MATLAB Style Guide

1. **Function Headers**:
```matlab
function [output1, output2] = my_function(input1, input2)
% MY_FUNCTION Brief one-line description
%
% Syntax:
%   [output1, output2] = my_function(input1, input2)
%
% Description:
%   Detailed description of what the function does.
%
% Inputs:
%   input1 - Description of input1
%   input2 - Description of input2
%
% Outputs:
%   output1 - Description of output1
%   output2 - Description of output2
%
% Example:
%   result = my_function(1, 2);
%
% See also: related_function1, related_function2

    % Implementation
end
```

2. **Variable Naming**:
```matlab
% Use descriptive names
electrodes_num = 16;           % Good
n = 16;                        % Bad

% Use underscores for multi-word variables
forward_model = ...            % Good
forwardModel = ...             % Avoid (Java style)
```

3. **Comments**:
```matlab
% Comment blocks for complex logic
% This section computes the Jacobian matrix using
% the adjoint method for efficiency

% Inline comments for clarity
z_contact = 0.01;  % Contact impedance in Ohms
```

4. **Error Handling**:
```matlab
if ~exist(config_file, 'file')
    error('Config file not found: %s', config_file);
end

try
    data = load(filename);
catch ME
    warning('Failed to load file: %s', ME.message);
    data = [];
end
```

### Code Organization

1. **Keep functions focused**: One function, one purpose
2. **Limit function length**: Aim for <100 lines
3. **Minimize globals**: Pass parameters explicitly
4. **Use subfunctions**: For helper code used only in one file

### Performance Guidelines

1. **Preallocate arrays**:
```matlab
% Good
results = zeros(n, m);
for i = 1:n
    results(i, :) = compute(i);
end

% Bad
results = [];
for i = 1:n
    results(i, :) = compute(i);  % Grows array each iteration
end
```

2. **Vectorize when possible**:
```matlab
% Good
conductivity = 10.^(log_values);

% Slower
for i = 1:length(log_values)
    conductivity(i) = 10^log_values(i);
end
```

3. **Profile before optimizing**:
```matlab
profile on
run_expensive_code();
profile viewer
```

---

## Contributing

### Before Contributing

1. **Read existing code**: Understand the style and patterns
2. **Check for duplicates**: Search for similar functionality
3. **Plan your changes**: Discuss major changes first

### Contribution Workflow

1. **Create a feature branch**:
```bash
git checkout -b feature/my-new-feature
```

2. **Make changes with clear commits**:
```bash
git commit -m "Add polygon shape support to features_parameters"
```

3. **Test thoroughly**:
```matlab
% Run all relevant test scripts
run test_my_feature.m
```

4. **Document your changes**:
- Update function headers
- Add to appropriate docs/*.md file
- Update CHANGELOG if applicable

5. **Submit for review**

### Documentation Requirements

For new functions:
- Complete function header with Syntax, Description, Inputs, Outputs
- Example usage in header or separate example script
- Entry in `docs/API_Reference.md`

For new features:
- Section in `docs/User_Guide.md` explaining usage
- Configuration options in `docs/Configuration_Guide.md`
- Developer notes in `docs/Development_Guide.md`

## See Also

- [API Reference](API_Reference.md) - Complete function documentation
- [User Guide](User_Guide.md) - How to use the toolkit
- [Configuration Guide](Configuration_Guide.md) - Parameter reference
