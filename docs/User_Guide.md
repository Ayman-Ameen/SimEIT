# SimEIT User Guide

This guide provides instructions for using the SimEIT dataset generation and analysis tools.

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Dataset Generation](#dataset-generation)
5. [Visualization](#visualization)
6. [Traditional Reconstruction Methods](#traditional-reconstruction-methods)
7. [Data Processing](#data-processing)

---

## Introduction

SimEIT is a MATLAB-based toolkit for generating and analyzing synthetic Electrical Impedance Tomography (EIT) datasets. It provides tools for:

- Generating realistic EIT forward models with customizable electrode configurations
- Creating synthetic conductivity distributions with multiple geometric shapes
- Computing forward solutions (voltage measurements)
- Visualizing meshes, images, and voltage data
- Benchmarking traditional reconstruction methods
- Downscaling and combining dataset patches

---

## Installation

### Prerequisites

1. **MATLAB** (R2019b or later recommended)
2. **EIDORS** (Electrical Impedance Tomography and Diffuse Optical Tomography Reconstruction Software)
   - Included in the `eidors/` directory
   - Will be automatically added to the path by the scripts

### Setup

1. Clone or download the repository to your local machine
2. Navigate to the project root directory
3. The scripts will automatically add necessary paths when executed

---

## Quick Start

### Generating Your First Dataset

1. **Configure the parameters** in `config.yaml`:
   ```yaml
   general:
     mode: simulation
     description: "My first EIT dataset"
   
   model:
     electrodes_num: 16
     resolution: 256
   
   dataset:
     number_of_samples: 100
     local_patch_size: 100
     patch_number: 0
   ```

2. **Run the dataset generation script**:
   ```matlab
   run generate_dataset.m
   ```

3. **Check the output** in the `../dataset/` directory

---

## Dataset Generation

### Main Script: `generate_dataset.m`

The main dataset generation script supports three modes:

#### 1. Simulation Mode
Generates synthetic conductivity distributions with random geometric shapes.

**Configuration**:
```yaml
general:
  mode: simulation

dataset:
  number_of_samples: 1000
  local_patch_size: 100
  patch_number: 0
```

**Features**:
- Generates random shapes (circles, ellipses, rectangles, triangles)
- Random conductivity values (log-uniform distribution)
- Non-overlapping constraints
- Coverage area tracking

#### 2. Simulation Test Mode
Tests the dataset generation with a single sample.

**Configuration**:
```yaml
general:
  mode: simulation_test

dataset:
  number_of_samples: 1
  local_patch_size: 1
  patch_number: 0
```

#### 3. Experimental Mode
Loads experimental data from external sources.

**Configuration**:
```yaml
general:
  mode: experimental
```

### Understanding the Output

The dataset is saved in HDF5 format with the following structure:

```
dataset.h5
├── /electrodes_16/
│   ├── /image_256/
│   │   ├── image           [N × 256 × 256]
│   │   ├── v_diff          [N × M measurements]
│   │   ├── img_elements    [N × Ne elements]
│   │   └── v_homo          [N × M measurements]
```

Where:
- `N` = number of samples
- `M` = number of voltage measurements
- `Ne` = number of finite elements

### Metadata Files

Metadata is stored in `../dataset/metadata/`:
- `dataset_id.mat` - Dataset identification information
- `volt/16/image_homogenous.mat` - Homogeneous model and Jacobian
- `data_patch_*.mat` - Per-patch metadata (shapes, conductivities, features)

---

## Visualization

### Visualizing Dataset Samples

Use `visualize_dataset_and_details.m` to explore your dataset:

```matlab
% Configure parameters
electrodes_num = 16;
resolution = 256;
patch_number = 0;

% Run visualization
run plots/visualize_dataset_and_details.m
```

**What it shows**:
- FEM mesh structure
- Conductivity distributions
- Voltage measurements
- Downscaled images at multiple resolutions

### Dataset Statistics

Generate statistical plots with:

```matlab
do_dataset_statistics = 1;
[data, img, v_homogeneous, patch_number, dataset_id] = ...
    get_patch_details(electrodes_num, resolution, dir_dataset, [], do_dataset_statistics);
```

**Generated plots**:
- Distribution of number of objects per sample
- Shape type frequencies
- Conductivity value distributions (log scale)
- Coverage area statistics

---

## Traditional Reconstruction Methods

### Running Reconstruction Methods

The `traditional_methods.m` script evaluates classical EIT reconstruction algorithms:

```matlab
% Configure
electrodes_num = 16;
resolution = 32;
resolution_reconstruct = 64;
methods_names = {'total_variation', 'Tikhonov_regularization_Gauss_Newton_solver'};
noise_all = [Inf, 10, 20, 30, 40, 50];  % SNR in dB

% Run
run traditional_methods/traditional_methods.m
```

### Available Methods

1. **Total Variation (TV)**
   - Promotes piecewise-constant solutions
   - Good for sharp boundaries
   - Reference: Borsic et al., 2010

2. **Tikhonov Regularization with Gauss-Newton**
   - Smooth regularization
   - Fast convergence
   - Standard inverse problem approach

3. **Backprojection**
   - Simple, fast reconstruction
   - Low quality but useful for quick checks

### Evaluation Metrics

The script computes:
- **Relative Error**: `||x - x_hat|| / ||x||`
- **Correlation Coefficient**: Similarity between ground truth and reconstruction

Results are saved as:
- PNG images of reconstructions
- XLS files with metric tables

---

## Data Processing

### Combining and Downscaling Patches

Use `combine_and_down_scale_dataset.m` to:
1. Combine multiple dataset patches
2. Downscale to lower resolutions
3. Generate graph representations

```matlab
% Configure
electrodes_num = 16;
resolution = 256;
new_resolutions = [32, 64, 128];
options = '_log';  % Apply log10 transform
graph = 1;         % Generate graph data

% Run
run combine_and_down_scale/combine_and_down_scale_dataset.m
```

**Output**: 
- HDF5 files with downscaled images at each resolution
- Graph representations (flattened arrays within circular mask)
- Useful for training neural networks at multiple scales

### Loading Data in Python

To use the generated HDF5 datasets in Python:

```python
import h5py
import numpy as np

# Open dataset
with h5py.File('../dataset/dataset.h5', 'r') as f:
    # Load images
    images = f['/electrodes_16/image_256/image'][:]
    
    # Load voltage measurements
    v_diff = f['/electrodes_16/image_256/v_diff'][:]
    
    # Load element data
    elements = f['/electrodes_16/image_256/img_elements'][:]

print(f"Loaded {images.shape[0]} samples")
print(f"Image shape: {images.shape[1:]}")
print(f"Voltage measurements: {v_diff.shape[1]}")
```

---

## Best Practices

### Performance Tips

1. **Batch Generation**: Generate datasets in patches for large datasets
   ```yaml
   dataset:
     local_patch_size: 1000  # Samples per patch
     patch_number: 0         # Increments automatically
   ```

2. **Resolution Selection**:
   - High resolution (256): Accurate but slow
   - Medium resolution (64): Good balance
   - Low resolution (32): Fast, suitable for quick tests

3. **Parallel Processing**: MATLAB's parallel toolbox can speed up some operations

### Reproducibility

- The `patch_number` acts as a random seed
- To reproduce a dataset, use the same `patch_number` and configuration
- Save your `config.yaml` with your dataset

### Data Quality

- Check statistics regularly with `dataset_statistics()`
- Verify no NaN values in outputs
- Use `test_dataset.m` to validate HDF5 file completeness

---

## Troubleshooting

### Common Issues

**Issue**: "Please, run the dataset first"
- **Solution**: Generate at least one patch before running analysis scripts

**Issue**: Out of memory errors
- **Solution**: Reduce `local_patch_size` or `resolution`

**Issue**: EIDORS functions not found
- **Solution**: Check that `eidors/startup.m` is being called

**Issue**: HDF5 write errors
- **Solution**: Ensure sufficient disk space and write permissions

---

## Next Steps

- Read the [API Reference](API_Reference.md) for detailed function documentation
- Check the [Configuration Guide](Configuration_Guide.md) for advanced settings
- See the [Development Guide](Development_Guide.md) to extend the toolkit

---

## Support

For questions, issues, or contributions:
- Check the existing documentation in `docs/`
- Review `paper.md` for theoretical background
- Examine example scripts in each directory

