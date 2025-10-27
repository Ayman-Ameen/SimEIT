# Configuration Guide

This document explains all configuration parameters in the SimEIT toolkit.

## Table of Contents

1. [Configuration File Structure](#configuration-file-structure)
2. [General Settings](#general-settings)
3. [Model Parameters](#model-parameters)
4. [Solver Configuration](#solver-configuration)
5. [Dataset Parameters](#dataset-parameters)
6. [Advanced Configuration](#advanced-configuration)

---

## Configuration File Structure

SimEIT uses a YAML configuration file (`config.yaml`) to manage all parameters. The file is structured into several sections:

```yaml
general:
  # General workflow settings
  
model:
  # Forward model parameters
  
solver:
  # Forward solver options
  
dataset:
  # Dataset generation parameters
```

---

## General Settings

### `general.mode`

**Type**: String  
**Options**: `'simulation'`, `'simulation_test'`, `'experimental'`  
**Default**: `'simulation'`

Determines the operation mode:
- **simulation**: Full dataset generation with synthetic data
- **simulation_test**: Quick test with a single sample
- **experimental**: Load and process experimental data

**Example**:
```yaml
general:
  mode: simulation
```

### `general.description`

**Type**: String  
**Default**: `"EIT Dataset"`

A description of the dataset for documentation purposes.

**Example**:
```yaml
general:
  description: "16-electrode circular EIT dataset with random shapes"
```

---

## Model Parameters

These parameters define the geometry and discretization of the forward model.

### `model.electrodes_num`

**Type**: Integer  
**Options**: Common values: 8, 16, 32  
**Default**: 16

Number of electrodes placed around the circular boundary.

**Impact**:
- More electrodes → higher spatial resolution
- More electrodes → more measurements (N × N pattern)
- 16 electrodes → 256 measurements (adjacent pattern)

**Example**:
```yaml
model:
  electrodes_num: 16
```

### `model.resolution`

**Type**: Integer  
**Options**: 32, 64, 128, 256  
**Default**: 256

Grid resolution for the finite element mesh and output images.

**Impact**:
- Higher resolution → more accurate but slower
- Higher resolution → larger file sizes
- 256 × 256 is typical for high-quality datasets

**Recommendations**:
- Development/testing: 64 or 128
- Production datasets: 256
- Fast experiments: 32

**Example**:
```yaml
model:
  resolution: 256
```

---

## Solver Configuration

Controls how the forward problem is solved.

### `solver.method_name`

**Type**: String  
**Options**: `'jacobian'`, `'forward'`  
**Default**: `'jacobian'`

Forward solution method:
- **jacobian**: Fast linear approximation using Jacobian matrix (J × Δσ)
- **forward**: Full nonlinear forward solve (accurate but slower)

**Example**:
```yaml
solver:
  method_name: jacobian
```

### `solver.reverse_simulation_pattern`

**Type**: Integer  
**Options**: 1, -1  
**Default**: 1

Sign convention for simulation pattern:
- 1: Standard convention
- -1: Reversed convention

**Example**:
```yaml
solver:
  reverse_simulation_pattern: 1
```

### `solver.rotation_angle`

**Type**: Float (degrees)  
**Default**: 0

Rotation angle for the stimulation/measurement pattern.

**Use case**: Data augmentation through rotation

**Example**:
```yaml
solver:
  rotation_angle: 0
```

### `solver.get_electrodes_resistance`

**Type**: Boolean (0 or 1)  
**Default**: 0

Whether to include electrode contact resistance:
- 0: Ideal electrodes (no contact impedance beyond z_contact)
- 1: Randomized contact resistance per sample

**Example**:
```yaml
solver:
  get_electrodes_resistance: 0
```

### `solver.get_volt_nodes`

**Type**: Boolean (0 or 1)  
**Default**: 0

Whether to compute and save nodal voltage distributions:
- 0: Only save boundary measurements
- 1: Save full 2D voltage field at nodes

**Warning**: Setting to 1 significantly increases memory and storage requirements.

**Example**:
```yaml
solver:
  get_volt_nodes: 0
```

---

## Dataset Parameters

Control dataset generation process.

### `dataset.number_of_samples`

**Type**: Integer  
**Default**: 1000

Total number of samples to generate in this run.

**Example**:
```yaml
dataset:
  number_of_samples: 5000
```

### `dataset.local_patch_size`

**Type**: Integer  
**Default**: 100

Number of samples per patch file. The dataset is generated in batches (patches) for memory efficiency.

**Total patches** = ceil(number_of_samples / local_patch_size)

**Recommendations**:
- Small datasets (<1000 samples): Use full size
- Large datasets: 100-1000 per patch
- Memory-constrained systems: Smaller patches

**Example**:
```yaml
dataset:
  local_patch_size: 500
```

### `dataset.patch_number`

**Type**: Integer  
**Default**: 0

Starting patch number (also serves as random seed):
- 0: Start new dataset
- N > 0: Continue from patch N (useful for resuming)

**Auto-increment**: The system automatically increments this for subsequent patches.

**Example**:
```yaml
dataset:
  patch_number: 0
```

---

## Advanced Configuration

### Shape Generation Parameters

These are hardcoded in `create_csv_dataset.m` but can be modified:

```matlab
max_number_of_objects = 4;  % 1-4 objects per sample
type_all_init = {'circle', 'ellipse', 'rectangle', 'triangle'};

% Conductivity range
maximum_conductivity = 10^6;   % S/m
minimum_conductivity = 10^-7;  % S/m
maximum_variation = 0.5;       % Per-object variation
```

### Electrode Configuration

In `generate_homogenous_image.m`:

```matlab
z_contact = 0.01;                    % Contact impedance (Ohm)
current_amplitude = 0.001;           % Stimulation current (A)
coverage_ratio = 0.21952 * 0.1963;   % Electrode coverage
number_virtual_electrodes = 16;      % For width calculation
```

### Mesh Quality Parameters

In `create_model.m` and `electrodes_nodes.m`:

```matlab
reinforcement_electrodes = 2;  % Boundary refinement factor
shift_electrodes = 0.005;      % Small shift for stability
```

---

## Configuration Examples

### Example 1: Quick Test Configuration

Fast generation for testing code changes:

```yaml
general:
  mode: simulation_test
  description: "Quick test dataset"

model:
  electrodes_num: 16
  resolution: 64

solver:
  method_name: jacobian
  reverse_simulation_pattern: 1
  rotation_angle: 0
  get_electrodes_resistance: 0
  get_volt_nodes: 0

dataset:
  number_of_samples: 10
  local_patch_size: 10
  patch_number: 0
```

### Example 2: High-Quality Production Dataset

For training neural networks:

```yaml
general:
  mode: simulation
  description: "High-quality 16-electrode dataset for deep learning"

model:
  electrodes_num: 16
  resolution: 256

solver:
  method_name: jacobian
  reverse_simulation_pattern: 1
  rotation_angle: 0
  get_electrodes_resistance: 0
  get_volt_nodes: 0

dataset:
  number_of_samples: 50000
  local_patch_size: 1000
  patch_number: 0
```

### Example 3: Multi-Resolution Dataset

Generate at one resolution, then downscale:

```yaml
# Step 1: config.yaml for generation
general:
  mode: simulation
  description: "Multi-resolution training set"

model:
  electrodes_num: 16
  resolution: 256

solver:
  method_name: jacobian
  reverse_simulation_pattern: 1
  rotation_angle: 0
  get_electrodes_resistance: 0
  get_volt_nodes: 0

dataset:
  number_of_samples: 10000
  local_patch_size: 500
  patch_number: 0
```

Then run `combine_and_down_scale_dataset.m` with:
```matlab
new_resolutions = [32, 64, 128];
```

### Example 4: Experimental Data Processing

```yaml
general:
  mode: experimental
  description: "ACT4 experimental data"

model:
  electrodes_num: 16
  resolution: 256

solver:
  method_name: forward
  reverse_simulation_pattern: 1
  rotation_angle: 0
  get_electrodes_resistance: 1  % Use measured contact resistance
  get_volt_nodes: 0

dataset:
  number_of_samples: 100
  local_patch_size: 100
  patch_number: 0
```

---

## Configuration Best Practices

### 1. Version Control
Always save your `config.yaml` alongside your dataset:
```bash
cp config.yaml ../dataset/config_used.yaml
```

### 2. Reproducibility
- Document the `patch_number` used
- Keep a log of configuration changes
- Use descriptive `description` fields

### 3. Resource Management

**Memory considerations**:
- `local_patch_size × resolution² × 8 bytes` ≈ memory per patch
- For resolution=256: ~500 MB per 100 samples

**Disk space**:
- Uncompressed HDF5: ~5-10 MB per sample at 256² resolution
- Downscaled versions reduce size significantly

### 4. Performance Tuning

**For speed**:
- Use `method_name: jacobian`
- Lower `resolution` during development
- Smaller `local_patch_size` for parallel processing

**For accuracy**:
- Use `method_name: forward` for validation
- Higher `resolution` for final datasets
- Enable `get_volt_nodes` only when needed

---

## Programmatic Configuration

You can also load and modify configuration in MATLAB:

```matlab
% Load config
config = load_config('config.yaml');

% Modify parameters
config.dataset.number_of_samples = 5000;
config.model.resolution = 128;

% Use in your code
electrodes_num = config.model.electrodes_num;
```

---

## Environment Variables

Some paths are auto-detected but can be overridden:

```matlab
% Override dataset directory
dir_dataset = '/custom/path/to/dataset/';
```

---

## See Also

- [User Guide](User_Guide.md) - How to use the toolkit
- [API Reference](API_Reference.md) - Function documentation
- [Development Guide](Development_Guide.md) - Extending the system
