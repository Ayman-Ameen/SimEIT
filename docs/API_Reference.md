# API Reference

This document provides detailed API documentation for all functions in the SimEIT_internal project.

## Table of Contents

- [Data Functions](#data-functions)
- [Generate Functions](#generate-functions)
- [Traditional Methods](#traditional-methods)
- [Plotting Functions](#plotting-functions)
- [Combine and Downscale](#combine-and-downscale)

---

## Data Functions

### create_csv_dataset

**Purpose**: Generate randomized shape metadata and write CSV/MAT files.

**Syntax**:
```matlab
data = create_csv_dataset(dir_dataset, number_of_samples, number_start_after, ...
    patch_number, number_of_features, save_data_name)
```

**Inputs**:
- `dir_dataset` - Directory path where outputs will be saved
- `number_of_samples` - Number of samples (rows) to generate
- `number_start_after` - Index offset multiplied by patch_number
- `patch_number` - Seed (for RNG) and index multiplier (batch id)
- `number_of_features` - Number of features per object
- `save_data_name` - Base filename (without extension) for outputs

**Output**:
- `data` - Table with columns: index1, number_of_objects, type, conductivity, features, coverage_area

**Notes**:
- All shapes' centers must lie inside the unit circle
- Conductivities are sampled log-uniformly per sample with limited variation

---

### features_parameters

**Purpose**: Sample non-overlapping shapes and return feature vectors.

**Syntax**:
```matlab
[features, types, coverage_area] = features_parameters(number_of_objects, type_all, ...
    features, dimension, number_of_features, dir_dataset, index1, conductivity)
```

**Description**: 
This function randomly proposes many candidate shapes, filters them by constraints (inside unit circle, minimum size, not degenerate), selects a non-intersecting subset, and returns the corresponding feature vectors and types for the requested number_of_objects.

---

### get_random_values_within_range

**Purpose**: Generate log-uniform random values per sample/object.

**Syntax**:
```matlab
conductivity = get_random_values_within_range(number_of_samples, max_number_of_objects, ...
    maximum_conductivity, minimum_conductivity, maximum_variation)
```

**Description**: 
Generates values that are uniformly distributed in log-space, using a per-sample base range with limited per-object variation.

**Inputs**:
- `number_of_samples` - Number of samples to generate
- `max_number_of_objects` - Number of objects (columns) per sample
- `maximum_conductivity` - Upper bound of the value range (linear scale)
- `minimum_conductivity` - Lower bound of the value range (linear scale)
- `maximum_variation` - Controls the per-object variation around each sample's base

**Output**:
- `conductivity` - [number_of_samples x max_number_of_objects] values

---

### load_config

**Purpose**: Load configuration from YAML file

**Syntax**:
```matlab
config = load_config()
config = load_config(config_file)
```

**Description**: 
Loads the SimEIT configuration from a YAML file and returns it as a struct. If no file is specified, looks for 'config.yaml' in the project root directory.

**Inputs**:
- `config_file` - (Optional) Path to the YAML configuration file

**Outputs**:
- `config` - Struct containing all configuration parameters

**Example**:
```matlab
config = load_config();
electrodes_num = config.model.electrodes_num;
```

**Author**: SimEIT Team  
**Date**: 2025

---

### not_intersect

**Purpose**: Find shapes that do not intersect

**Syntax**:
```matlab
index_shapes = not_intersect(cnf_matrix, number_of_objects)
```

**Description**: 
Searches for shapes that do not intersect by analyzing a confusion matrix.

**Inputs**:
- `cnf_matrix` - Confusion matrix indicating shape intersections
- `number_of_objects` - Number of non-intersecting objects to find

**Outputs**:
- `index_shapes` - Indices of shapes that do not intersect

---

### object2str

**Purpose**: Generate string equation for a geometric object

**Syntax**:
```matlab
object_str = object2str(origin, size_or_theta, type, dimension)
```

**Description**: 
Generates a string equation representing a geometric object that can be used for shape definitions in EIDORS or other computational geometry contexts.

**Inputs**:
- `origin` - Object position/vertices (varies by shape type)
- `size_or_theta` - Size parameter or rotation angle (depends on shape)
- `type` - Shape type: 'circle', 'ellipse', 'rectangle', 'triangle'
- `dimension` - Dimension: '2d' (currently only 2D supported)

**Outputs**:
- `object_str` - String equation defining the object geometry

---

## Generate Functions

### create_model

**Purpose**: Build a 2D circular EIT forward model.

**Syntax**:
```matlab
model_fwd = create_model(resolution, dimension, z_contact, scale, shape_function, ...
    coverage_ratio, number_virtual_electrodes, electrodes_number, reinforcement_electrodes)
```

**Description**: 
Constructs an EIDORS forward model for a unit circle domain (scaled by "scale") with the requested electrode layout and contact impedance.

**Inputs**:
- `resolution` - Number of grid points along x/y for node generation
- `dimension` - '2d' (currently supported)
- `z_contact` - Contact impedance (Ohm)
- `scale` - [sx, sy, sz] geometric scaling factors
- `shape_function` - 'unit_circle' or a function handle @(x,y)mask
- `coverage_ratio` - Electrode coverage ratio of the perimeter (0..0.9)
- `number_virtual_electrodes` - Virtual electrode count used to define widths
- `electrodes_number` - Actual number of electrodes on the boundary
- `reinforcement_electrodes` - Refinement factor for boundary point density

**Output**:
- `model_fwd` - EIDORS forward model struct

---

### electrodes_nodes

**Purpose**: Generate boundary nodes for electrodes and perimeter.

**Syntax**:
```matlab
[electrodesNodes, perimeter_nodes, electrodesNodesSupport] = electrodes_nodes(resolution, ...
    reinforcement_electrodes, shape, coverage_ratio, number_virtual_electrodes, ...
    electrodes_number, min_value_to_electrodes)
```

**Description**: 
Computes arc samples along a unit-circle boundary to represent electrode segments and non-electrode perimeter segments.

**Inputs**:
- `resolution` - Grid resolution used to scale point counts
- `reinforcement_electrodes` - Multiplier for boundary sampling density
- `shape` - 'unit_circle' supported
- `coverage_ratio` - Fraction of perimeter covered by electrodes
- `number_virtual_electrodes` - Virtual electrodes used to size widths
- `electrodes_number` - Actual number of electrodes around boundary
- `min_value_to_electrodes` - Reserved (unused), kept for API compatibility

**Outputs**:
- `electrodesNodes` - Cell array of [x,y] points for each electrode
- `perimeter_nodes` - Cell array of [x,y] points for gaps between electrodes
- `electrodesNodesSupport` - Cell array of [x,y] points spanning each sector

---

### find_boundary_circle

**Purpose**: Compute boundary edges for a circular mesh.

**Syntax**:
```matlab
boundary = find_boundary_circle(boundary_nodes, nodes, elements)
```

**Description**: 
Returns the list of element-edge node indices that lie entirely on the provided boundary_nodes set.

**Inputs**:
- `boundary_nodes` - [Kx2] coordinates of points on the circle boundary
- `nodes` - [Nx2] mesh node coordinates
- `elements` - [Mx3] triangular elements as node indices

**Output**:
- `boundary` - [Bx2] sorted node index pairs forming boundary edges

---

### forward_solver_for_one_sample

**Purpose**: Compute EIT forward response for one sample.

**Syntax**:
```matlab
[v_homo, img_elements, v_diff, image, image_electric_volt] = ...
    forward_solver_for_one_sample(jacobian, img, elem_data_all, single_image, ...
    method, background_conductivity)
```

**Description**: 
Computes the homogeneous and target measurements and their difference either via a Jacobian-based linearization or the full forward solver.

**Inputs**:
- `jacobian` - System Jacobian (used when method.name == 'jacobian')
- `img` - EIDORS image struct (contains fwd_model)
- `elem_data_all` - Element-wise conductivity deltas
- `single_image` - Image grid of conductivity deltas
- `method` - Struct with fields: name, reverse_simulation_pattern, get_volt_nodes
- `background_conductivity` - Background conductivity scalar

**Outputs**:
- `v_homo` - Homogeneous measurements (vector)
- `img_elements` - Element-wise conductivities for target image
- `v_diff` - Difference measurements (target - homo)
- `image` - Background + single_image
- `image_electric_volt` - 4D (mode x stim x Ny x Nx) voltage images, or 'N/A'

---

### generate_homogenous_image

**Purpose**: Create a homogeneous EIT image and solve v_homo.

**Syntax**:
```matlab
[img, v_homogeneous] = generate_homogenous_image(resolution, electrodes_num)
```

**Description**: 
Builds a circular forward model with the given number of electrodes and returns the EIDORS image struct and its homogeneous forward solution.

**Inputs**:
- `resolution` - Grid resolution used to build the model
- `electrodes_num` - Number of boundary electrodes

**Outputs**:
- `img` - EIDORS image struct with stimulation set
- `v_homogeneous` - Result of fwd_solve(img)

---

### generate_patch

**Purpose**: Generate synthetic/experimental patches and forward data.

**Syntax**:
```matlab
[image, v_diff, img_elements, v_homo, electrodes_contact_resistance] = ...
    generate_patch(data, img, jacobian, number_of_features, v_homogeneous, ...
    resolution, mode, method)
```

**Description**: 
Constructs per-sample element conductivity maps from object descriptors or experimental masks, solves forward responses, and returns image grids and measurement vectors.

**Inputs**:
- `data` - Structure or array holding features/masks
- `img` - EIDORS image struct with fwd_model
- `jacobian` - System Jacobian (for linear method)
- `number_of_features` - Features per object descriptor (synthetic mode)
- `v_homogeneous` - Homogeneous forward solution struct
- `resolution` - Output image resolution (Ny == Nx)
- `mode` - 'synthetic' or 'experimental'
- `method` - Struct controlling solver mode and options

**Outputs**:
- `image` - [N x res x res] grid images per sample
- `v_diff` - [N x M] differential measurements
- `img_elements` - [N x Ne] element conductivities
- `v_homo` - [N x M] homogeneous measurements
- `electrodes_contact_resistance` - Per-sample contact resistances or []

---

### get_electrodes_resistance

**Purpose**: Calculate electrode contact resistance values

**Syntax**:
```matlab
[electrodes_contact_resistance, patch_size] = get_electrodes_resistance(data, ...
    length_of_meas, electrodes_num, mode, method)
```

**Inputs**:
- `data` - Dataset containing images or measurements
- `length_of_meas` - Length of measurement vector
- `electrodes_num` - Number of electrodes
- `mode` - 'experimental' or 'simulation' mode
- `method` - Structure with get_electrodes_resistance flag

**Outputs**:
- `electrodes_contact_resistance` - Matrix of resistance values or empty
- `patch_size` - Size of the patch dataset

---

### get_patch_details

**Purpose**: Retrieve patch details from existing dataset

**Syntax**:
```matlab
[data, img, v_homogeneous, patch_number, dataset_id] = get_patch_details(electrodes_num, ...
    resolution, dir_dataset, patch_number, do_dataset_statistics)
```

**Description**: 
Reads the patch number if it exists and loads the associated metadata including homogeneous image, voltage data, and dataset information.

**Inputs**:
- `electrodes_num` - Number of electrodes in the system
- `resolution` - Resolution of the mesh/image
- `dir_dataset` - Directory path to the dataset
- `patch_number` - Patch number to load (if empty, reads from file)
- `do_dataset_statistics` - Flag to compute dataset statistics

**Outputs**:
- `data` - Combined dataset from all patches
- `img` - Homogeneous image model
- `v_homogeneous` - Homogeneous voltage measurements
- `patch_number` - Current patch number
- `dataset_id` - Dataset identification information

---

### get_patch_init

**Purpose**: Initialize or retrieve patch data for dataset generation

**Syntax**:
```matlab
[data, img, v_homogeneous, jacobian, patch_number, dataset_id] = get_patch_init(electrodes_num, ...
    resolution, dir_dataset, patch_number, number_of_samples)
```

**Description**: 
Initializes a new dataset patch or retrieves an existing one. If patch_number is 0, creates a new homogeneous image, calculates jacobian, and initializes dataset metadata. Otherwise, loads existing data.

**Inputs**:
- `electrodes_num` - Number of electrodes in the system
- `resolution` - Resolution of the mesh/image
- `dir_dataset` - Directory path to the dataset
- `patch_number` - Current patch number (0 for new initialization)
- `number_of_samples` - Number of samples to generate per patch

**Outputs**:
- `data` - Dataset table for current patch
- `img` - Homogeneous image model
- `v_homogeneous` - Homogeneous voltage measurements
- `jacobian` - Jacobian matrix for the model
- `patch_number` - Current or incremented patch number
- `dataset_id` - Dataset identification information

---

### get_patch_number

**Purpose**: Retrieve or initialize patch number from dataset directory

**Syntax**:
```matlab
patch_number = get_patch_number(dir_patch_num, patch_number)
```

**Description**: 
Manages the patch numbering system for dataset generation. If patch_number is provided (not empty), returns it unchanged. Otherwise, loads the current patch number from file and increments it, or initializes to 0 if the file doesn't exist.

**Inputs**:
- `dir_patch_num` - Directory path where patch_number.mat is stored
- `patch_number` - Existing patch number (if empty, loads from file)

**Outputs**:
- `patch_number` - Current or incremented patch number

---

### make_simulation_pattern_with_ground

**Purpose**: Generate stimulation and measurement patterns

**Syntax**:
```matlab
stim_patterns = make_simulation_pattern_with_ground(current_amplitude, num_electrodes)
```

**Description**: 
Creates stimulation and measurement patterns for adjacent electrode configuration in Electrical Impedance Tomography (EIT).

**Inputs**:
- `current_amplitude` - Amplitude of stimulation current
- `num_electrodes` - Number of electrodes in the system

**Outputs**:
- `stim_patterns` - Stimulation and measurement pattern structure. Matrix format: [stim+, stim-, meas+, meas-] x N_patterns

---

### read_patch_number

**Purpose**: Reads the patch number from the dataset directory

**Syntax**:
```matlab
patch_number = read_patch_number(dir_patch_num, patch_number)
```

**Inputs**:
- `dir_patch_num` - Directory containing the patch_number.mat file
- `patch_number` - Existing patch number (if provided, function returns immediately)

**Output**:
- `patch_number` - The patch number from file, or empty if not found

---

### save_hdf5

**Purpose**: Saves data to HDF5 dataset

**Syntax**:
```matlab
save_hdf5(filename, field_names, dataset_current, output, ChunkSize, counter_patch, dir_dataset)
```

**Inputs**:
- `filename` - HDF5 file path
- `field_names` - Cell array of field names to save
- `dataset_current` - Current dataset path within HDF5 structure
- `output` - Cell array containing data to save
- `ChunkSize` - Chunk size for HDF5 dataset creation
- `counter_patch` - Current patch counter for indexing
- `dir_dataset` - Dataset directory path

---

### select_grid_elements

**Purpose**: Selects elements based on a binary mask

**Syntax**:
```matlab
elem_data = select_grid_elements(elements, X, Y, x_space, y_space, binary_mask, ...
    round_value, nodes_round)
```

**Inputs**:
- `elements` - Array of element definitions
- `X` - X-coordinates grid
- `Y` - Y-coordinates grid
- `x_space` - Spacing in X direction
- `y_space` - Spacing in Y direction
- `binary_mask` - Binary mask for element selection
- `round_value` - Number of decimal places for rounding
- `nodes_round` - Rounded node coordinates

**Output**:
- `elem_data` - Binary array indicating selected elements

---

### set_electrodes_resistance

**Purpose**: Sets the contact resistance for electrodes

**Syntax**:
```matlab
img = set_electrodes_resistance(img, method, counter, experimental_bias_contact_resistance, data)
```

**Inputs**:
- `img` - Image structure containing forward model
- `method` - Structure with method parameters
- `counter` - Current iteration counter
- `experimental_bias_contact_resistance` - Bias for experimental contact resistance
- `data` - Data structure containing measurements

**Output**:
- `img` - Updated image structure with modified electrode contact resistance

---

### test_dataset

**Purpose**: Tests the dataset and determines which patches are incomplete

**Description**: 
This script validates the completeness of HDF5 dataset patches by checking for missing or zero-valued data in image, voltage, and element arrays.

---

## Traditional Methods

### traditional_methods

**Purpose**: Solve dataset test samples with traditional EIT reconstruction methods

**Description**: 
This script reconstructs EIT images from test samples using traditional inverse problem solving methods such as Total Variation, Tikhonov regularization, and Gauss-Newton solvers. It evaluates performance across different noise levels and saves reconstruction results and metrics.

**Configuration Parameters**:
- `electrodes_num` - Number of electrodes (default: 16)
- `resolution` - Image resolution (default: 32)
- `resolution_reconstruct` - Reconstruction resolution (default: 64)
- `methods_names` - Cell array of method names to evaluate
- `noise_all` - Array of noise levels to test (default: [Inf, 10, 20, 30, 40, 50])

**Output**:
- Reconstructed images saved as PNG and XLS files
- Correlation coefficient and relative error metrics saved as XLS files

---

### add_noise

**Purpose**: Adds Gaussian noise to a signal at a specified SNR (dB)

**Syntax**:
```matlab
signal = add_noise(signal, SNR_dB)
```

**Description**: 
Adds random noise to the input signal based on the desired SNR in dB.

---

### convert_mesh_to_image_and_norm_and_scale

**Purpose**: Converts mesh data to normalized and scaled image

**Syntax**:
```matlab
[image_resized, the_figure, save_properties] = convert_mesh_to_image_and_norm_and_scale(...
    the_figure, save_properties, element_data, img, resolution_convert, resoultion_scale, ...
    colormap_for_patch)
```

**Description**: 
Converts mesh data to an image, normalizes, and rescales it.

---

### error_and_similarity

**Purpose**: Computes relative error and correlation coefficient between two signals

**Syntax**:
```matlab
[relative_error, correlation_coefficient] = error_and_similarity(x, x_hat)
```

**Description**: 
Returns the relative error and correlation coefficient between x and x_hat.

---

### get_solver

**Purpose**: Creates an inverse model solver for EIT reconstruction

**Syntax**:
```matlab
[inverse_model, metadata] = get_solver(name, resolution_reconstruct, electrodes_num)
```

**Inputs**:
- `name` - String specifying the solver method:
  - 'total_variation'
  - 'Tikhonov_prior'
  - 'Gauss-Newton'
  - 'Tikhonov_regularization_Gauss_Newton_solver'
  - 'Backprojection'
- `resolution_reconstruct` - Resolution for the reconstructed image
- `electrodes_num` - Number of electrodes in the EIT system

**Outputs**:
- `inverse_model` - EIDORS inverse model object configured with the specified solver
- `metadata` - Structure containing reference papers and documentation links

**See also**: generate_homogenous_image, inv_solve

---

### get_test_indices

**Purpose**: Retrieves dataset test indices from parameters file

**Syntax**:
```matlab
testIndices = get_test_indices(dir_dataset)
```

**Input**:
- `dir_dataset` - Path to the dataset directory containing parameters folder

**Output**:
- `testIndices` - Array of test indices (1-indexed for MATLAB)

**Description**: 
This function reads the test.txt file from the parameters subdirectory and converts the indices from Python format (0-indexed) to MATLAB format (1-indexed).

**See also**: readtable

---

### get_figure

**Purpose**: Creates a figure with specific properties for saving and visualization

**Syntax**:
```matlab
[the_figure, save_properties] = get_figure()
```

**Description**: 
Returns a figure handle and a struct with save/display properties.

---

## Plotting Functions

### dataset_statistics

**Purpose**: Generate and save dataset statistics plots.

**Syntax**:
```matlab
dataset_statistics(data, dir_dataset_metadata)
```

**Inputs**:
- `data` - Table with dataset metadata. Expected columns: number_of_objects, type (cell array per object), conductivity (numeric per object), coverage_area
- `dir_dataset_metadata` - Base directory of the dataset metadata; plots will be saved under plot/statistics

**Description**: 
This function computes and visualizes several statistics:
- Distribution of the number of objects
- Types of objects overall and per object count
- Conductivity distribution overall and per object count (log10 scale)
- Coverage area distribution overall and per object count

---

### load_hdf5

**Purpose**: Load fields from MAT or HDF5 datasets.

**Syntax**:
```matlab
output = load_hdf5(filename, field_names, dataset_current, typeOutput, dir_dataset, start)
```

**Inputs**:
- `filename` - Full path to the HDF5 file (used when typeOutput='float')
- `field_names` - Cell array of field names to load
- `dataset_current` - Base dataset path/prefix. For HDF5, this is the group path; for MAT, it's the relative path under dir_dataset
- `typeOutput` - 'mat' to load from .mat files, 'float' to load from HDF5
- `dir_dataset` - Base directory for MAT files (used when typeOutput='mat')
- `start` - Optional starting index for reading along the first dimension in HDF5 ([] to read all)

**Output**:
- `output` - 1-by-N cell array with loaded variables per field name

---

### show_fem_dataset

**Purpose**: Display FEM mesh using EIDORS.

**Syntax**:
```matlab
h = show_fem_dataset(h, number_of_subplots, counter_subplot, img)
```

**Inputs**:
- `h` - Figure handle to plot into
- `number_of_subplots` - Subplots per row/column (n creates n-by-n grid)
- `counter_subplot` - Subplot index (position in the grid)
- `img` - EIDORS image object to display

**Output**:
- `h` - The same figure handle (for chaining)

---

### visualize_dataset_and_details

**Purpose**: Visualize dataset samples: FEM mesh, voltages, and image data.

**Description**: 
This script loads and displays samples from the dataset including FEM meshes, voltage measurements, and reconstructed images at various resolutions.

---

## Combine and Downscale

### combine_and_down_scale_dataset

**Purpose**: Combine dataset patches and downscale them to multiple resolutions

**Description**: 
This script combines dataset patches and downscales them to multiple resolutions, saving the results to HDF5 files. It processes images and voltage measurements, creates downscaled versions, and generates graph representations.

**Parameters to configure**:
- `electrodes_num` - Number of electrodes (default: 16)
- `resolution` - Original image resolution (default: 256)
- `new_resolutions` - Target resolutions for downscaling (default: [32,64,128])
- `options` - Scaling option, '_log' for logarithmic (default: '_log')
- `graph` - Enable graph generation (default: 1)

---

### downscale_patch

**Purpose**: Downscale images to multiple resolutions

**Syntax**:
```matlab
[output, output_graph] = downscale_patch(image, new_resolutions, options)
```

**Inputs**:
- `image` - Original image array (l x width x height)
- `new_resolutions` - Array of target resolutions (e.g., [32, 64, 128])
- `options` - Scaling option: '_log' for logarithmic scaling

**Outputs**:
- `output` - Cell array of downscaled images for each resolution
- `output_graph` - Cell array of flattened graph representations within circle mask

**Description**: 
This function downscales images to multiple target resolutions using bilinear interpolation. If log scaling is enabled, it applies log10 transformation. The function also creates graph representations by flattening the images within a circular binary mask.

---

## See Also

- [User Guide](User_Guide.md)
- [Configuration Guide](Configuration_Guide.md)
- [Development Guide](Development_Guide.md)
