# SimEIT Documentation Index

Welcome to the SimEIT (Simulation of Electrical Impedance Tomography) documentation.

## Quick Links

- **New Users**: Start with the [User Guide](User_Guide.md)
- **Function Reference**: See [API Reference](API_Reference.md)
- **Configuration Help**: Check [Configuration Guide](Configuration_Guide.md)
- **Developers**: Read [Development Guide](Development_Guide.md)
- **Project Overview**: See [Overview](overview.md)

---

## What is SimEIT?

SimEIT is a MATLAB-based toolkit for generating and analyzing synthetic Electrical Impedance Tomography (EIT) datasets. It provides:

- **Forward Model Generation**: Create 2D circular EIT models with customizable electrode configurations
- **Synthetic Data Creation**: Generate datasets with random geometric shapes and conductivity distributions
- **Forward Problem Solving**: Compute voltage measurements using EIDORS (linear Jacobian or full nonlinear)
- **Traditional Reconstruction Methods**: Benchmark inverse solvers (Total Variation, Tikhonov, etc.)
- **Visualization Tools**: Plot meshes, images, voltages, and statistics
- **Data Processing**: Downscale, combine, and export datasets for machine learning

---

## Documentation Structure

### [User Guide](User_Guide.md)
**For**: End users, researchers, students  
**Contents**:
- Installation instructions
- Quick start tutorial
- Dataset generation workflow
- Visualization examples
- Traditional reconstruction methods
- Data processing and export
- Troubleshooting

**Start here if you want to**: Generate datasets, visualize results, run benchmarks

---

### [API Reference](API_Reference.md)
**For**: Users needing detailed function documentation  
**Contents**:
- Complete function signatures
- Input/output descriptions
- Usage examples
- Organized by module:
  - Data Functions
  - Generate Functions
  - Traditional Methods
  - Plotting Functions
  - Combine and Downscale

**Start here if you want to**: Look up specific function parameters, understand return values

---

### [Configuration Guide](Configuration_Guide.md)
**For**: Users customizing dataset generation  
**Contents**:
- Configuration file structure (YAML)
- Parameter descriptions and defaults
- Configuration examples for different use cases
- Best practices for resource management
- Performance tuning tips

**Start here if you want to**: Customize electrode numbers, resolution, solver methods, batch sizes

---

### [Development Guide](Development_Guide.md)
**For**: Developers extending the toolkit  
**Contents**:
- Architecture overview
- Code organization
- Data flow diagrams
- Adding new features (shapes, solvers, etc.)
- Testing strategies
- Coding standards
- Contributing guidelines

**Start here if you want to**: Add new shape types, implement custom solvers, contribute code

---

### [Overview](overview.md)
**For**: Project understanding and context  
**Contents**:
- High-level project goals
- System architecture
- Key concepts in EIT
- Design decisions

**Start here if you want to**: Understand the big picture, learn EIT basics

---

## Getting Started in 5 Minutes

### Step 1: Configure
Edit `config.yaml`:
```yaml
general:
  mode: simulation
  description: "My first dataset"

model:
  electrodes_num: 16
  resolution: 256

dataset:
  number_of_samples: 100
  local_patch_size: 100
  patch_number: 0
```

### Step 2: Generate
```matlab
run generate_dataset.m
```

### Step 3: Visualize
```matlab
cd plots
run visualize_dataset_and_details.m
```

### Step 4: Explore
Your data is in `../dataset/dataset.h5`

---

## Key Concepts

### Electrical Impedance Tomography (EIT)
- **Goal**: Reconstruct internal conductivity from boundary voltage measurements
- **Setup**: Current injected through electrodes, voltages measured at other electrodes
- **Application**: Medical imaging, process monitoring, geophysics

### Forward Problem
- **Input**: Conductivity distribution σ(x,y)
- **Output**: Boundary voltage measurements v
- **Method**: Finite element solution of Laplace equation: ∇·(σ∇u) = 0

### Inverse Problem
- **Input**: Voltage measurements v
- **Output**: Estimated conductivity σ̂(x,y)
- **Challenge**: Ill-posed, requires regularization

### Dataset Structure
```
dataset.h5
├── /electrodes_16/
│   └── /image_256/
│       ├── image         [N × 256 × 256]  Conductivity maps
│       ├── v_diff        [N × M]          Differential voltages
│       ├── img_elements  [N × Ne]         Element conductivities
│       └── v_homo        [N × M]          Homogeneous voltages
```

---

## Common Workflows

### Workflow 1: Generate Training Dataset
1. Configure: Set `number_of_samples`, `resolution`, `electrodes_num`
2. Generate: Run `generate_dataset.m`
3. Downscale: Run `combine_and_down_scale_dataset.m`
4. Export to Python for training

### Workflow 2: Benchmark Reconstruction Methods
1. Generate test set with `mode: simulation`
2. Export test indices
3. Run `traditional_methods.m` with multiple solvers
4. Compare metrics (correlation, relative error)

### Workflow 3: Analyze Dataset Statistics
1. Generate dataset
2. Set `do_dataset_statistics = 1` in scripts
3. View plots in `../dataset/metadata/plot/statistics/`

---

## Module Overview

### data_functions/
**Purpose**: Create synthetic metadata  
**Key Functions**:
- `create_csv_dataset`: Generate random shapes and conductivities
- `features_parameters`: Sample and validate non-overlapping shapes
- `load_config`: Parse YAML configuration

### generate_functions/
**Purpose**: Build forward models and solve  
**Key Functions**:
- `create_model`: Build EIDORS finite element model
- `generate_patch`: Generate samples from metadata
- `forward_solver_for_one_sample`: Compute voltage measurements

### traditional_methods/
**Purpose**: Inverse problem solvers  
**Key Functions**:
- `get_solver`: Configure reconstruction methods
- `traditional_methods`: Evaluation script

### plots/
**Purpose**: Visualization  
**Key Functions**:
- `visualize_dataset_and_details`: Interactive dataset explorer
- `dataset_statistics`: Generate statistical plots
- `show_fem_dataset`: Display FEM meshes

### combine_and_down_scale/
**Purpose**: Post-processing  
**Key Functions**:
- `combine_and_down_scale_dataset`: Merge patches and downscale
- `downscale_patch`: Multi-resolution image generation

---

## File Formats

### Configuration: YAML
```yaml
general:
  mode: simulation
model:
  electrodes_num: 16
  resolution: 256
```

### Dataset: HDF5
- **Advantages**: Efficient for large arrays, partial I/O, Python/MATLAB compatible
- **Access in MATLAB**: `h5read('dataset.h5', '/path/to/data')`
- **Access in Python**: `h5py.File('dataset.h5', 'r')`

### Metadata: MAT files
- MATLAB native format
- Stored in `../dataset/metadata/`

---

## Performance Considerations

### Memory
- **Resolution 256**: ~2 MB per sample (uncompressed)
- **Batch size**: Recommend 100-1000 samples per patch
- **Monitor**: Use MATLAB's memory profiler

### Speed
- **Jacobian method**: ~10-50 samples/sec (resolution 256)
- **Forward method**: ~1-10 samples/sec
- **Bottleneck**: Usually mesh generation or file I/O

### Storage
- **Raw dataset**: ~5-10 MB per sample at 256² resolution
- **Downscaled**: ~0.1-1 MB per sample
- **Compression**: HDF5 supports gzip (enable with h5create options)

---

## Troubleshooting Quick Reference

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| "EIDORS not found" | Path not set | Run `eidors/startup.m` |
| Out of memory | Dataset too large | Reduce `local_patch_size` or `resolution` |
| "Please run dataset first" | No existing patches | Generate at least one patch |
| NaN in outputs | Solver instability | Check conductivity ranges, mesh quality |
| Slow generation | High resolution + full forward | Use `method_name: jacobian` or lower resolution |

---

## External Resources

### EIDORS
- **Website**: http://eidors3d.sourceforge.net/
- **Documentation**: http://eidors3d.sourceforge.net/tutorial/tutorial.shtml
- **Papers**: EIDORS reference papers in tutorial

### EIT Background
- **Book**: "Electrical Impedance Tomography" by Holder (Ed.)
- **Review**: Adler & Lionheart, "Uses and abuses of EIDORS"

### MATLAB
- **Documentation**: https://www.mathworks.com/help/matlab/
- **HDF5**: https://www.mathworks.com/help/matlab/hdf5-files.html

---

## Version Information

- **MATLAB**: R2022b or later recommended
- **EIDORS**: Version included in repository
- **Dependencies**: Signal Processing Toolbox (optional, for some plots)

---

## Support and Contact

For issues, questions, or contributions:
1. Check this documentation
2. Review example scripts in each directory
3. See our paper for theoretical background
4. Check EIDORS documentation for FEM-related questions

---

## License

See `LICENSE` file in repository root.

---

## Changelog

See `CHANGES` for version history and updates.

---

## Citation

If you use SimEIT in your research, please cite:
- [Add citation information when available]
- EIDORS citation: [See eidors/info.xml]

---

*Last updated: 2025*
