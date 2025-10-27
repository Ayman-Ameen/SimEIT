# Function Documentation Summary

This document provides a quick reference to all documented functions in SimEIT, organized by category.

## Quick Function Finder

### Configuration & Setup
| Function | Purpose | Location |
|----------|---------|----------|
| `load_config` | Parse YAML configuration file | data_functions/ |

### Model Creation
| Function | Purpose | Location |
|----------|---------|----------|
| `create_model` | Build 2D circular EIT forward model | generate_functions/ |
| `electrodes_nodes` | Generate boundary nodes for electrodes | generate_functions/ |
| `find_boundary_circle` | Compute boundary edges for circular mesh | generate_functions/ |
| `generate_homogenous_image` | Create homogeneous EIT image | generate_functions/ |
| `make_simulation_pattern_with_ground` | Generate stim/measurement patterns | generate_functions/ |

### Dataset Generation
| Function | Purpose | Location |
|----------|---------|----------|
| `create_csv_dataset` | Generate randomized shape metadata | data_functions/ |
| `features_parameters` | Sample non-overlapping shapes | data_functions/ |
| `get_random_values_within_range` | Generate log-uniform random values | data_functions/ |
| `object2str` | Generate geometric object string equation | data_functions/ |
| `not_intersect` | Find non-intersecting shapes | data_functions/ |

### Patch Management
| Function | Purpose | Location |
|----------|---------|----------|
| `generate_patch` | Generate synthetic/experimental patches | generate_functions/ |
| `get_patch_init` | Initialize or retrieve patch data | generate_functions/ |
| `get_patch_details` | Retrieve patch details from dataset | generate_functions/ |
| `get_patch_number` | Get or initialize patch number | generate_functions/ |
| `read_patch_number` | Read patch number from file | generate_functions/ |

### Forward Problem
| Function | Purpose | Location |
|----------|---------|----------|
| `forward_solver_for_one_sample` | Compute EIT forward response | generate_functions/ |
| `select_grid_elements` | Select elements based on binary mask | generate_functions/ |
| `get_electrodes_resistance` | Calculate electrode contact resistance | generate_functions/ |
| `set_electrodes_resistance` | Set contact resistance for electrodes | generate_functions/ |

### Inverse Problem (Traditional Methods)
| Function | Purpose | Location |
|----------|---------|----------|
| `get_solver` | Create inverse model solver | traditional_methods/ |
| `add_noise` | Add Gaussian noise at specified SNR | traditional_methods/ |
| `error_and_similarity` | Compute error and correlation metrics | traditional_methods/ |
| `get_test_indices` | Retrieve dataset test indices | traditional_methods/ |
| `convert_mesh_to_image_and_norm_and_scale` | Convert mesh to normalized image | traditional_methods/ |
| `get_figure` | Create figure with save properties | traditional_methods/ |

### Data I/O
| Function | Purpose | Location |
|----------|---------|----------|
| `save_hdf5` | Save data to HDF5 dataset | generate_functions/ |
| `load_hdf5` | Load fields from MAT or HDF5 | plots/ |

### Visualization
| Function | Purpose | Location |
|----------|---------|----------|
| `dataset_statistics` | Generate and save dataset statistics plots | plots/ |
| `show_fem_dataset` | Display FEM mesh using EIDORS | plots/ |

### Post-Processing
| Function | Purpose | Location |
|----------|---------|----------|
| `downscale_patch` | Downscale images to multiple resolutions | combine_and_down_scale/ |

### Scripts
| Script | Purpose | Location |
|--------|---------|----------|
| `generate_dataset.m` | Main dataset generation script | root |
| `traditional_methods.m` | Benchmark reconstruction methods | traditional_methods/ |
| `test_dataset.m` | Validate dataset completeness | generate_functions/ |
| `combine_and_down_scale_dataset.m` | Combine patches and downscale | combine_and_down_scale/ |
| `visualize_dataset_and_details.m` | Interactive dataset visualization | plots/ |

---

## Function Call Graph

### Dataset Generation Pipeline
```
generate_dataset.m
├── load_config()
├── get_patch_init()
│   ├── generate_homogenous_image()
│   │   ├── create_model()
│   │   │   └── electrodes_nodes()
│   │   └── make_simulation_pattern_with_ground()
│   └── create_csv_dataset()
│       ├── get_random_values_within_range()
│       └── features_parameters()
│           ├── object2str()
│           └── not_intersect()
├── generate_patch()
│   ├── get_electrodes_resistance()
│   ├── select_grid_elements()
│   ├── set_electrodes_resistance()
│   └── forward_solver_for_one_sample()
└── save_hdf5()
```

### Reconstruction Pipeline
```
traditional_methods.m
├── get_patch_details()
├── get_test_indices()
├── get_solver()
├── add_noise()
├── inv_solve() [EIDORS]
├── convert_mesh_to_image_and_norm_and_scale()
│   └── get_figure()
└── error_and_similarity()
```

---

## Common Function Patterns

### Configuration Functions
All accept `config` struct or individual parameters from config:
```matlab
config = load_config('config.yaml');
electrodes_num = config.model.electrodes_num;
```

### Patch Functions
Follow naming convention `get_patch_*` or `*_patch`:
```matlab
[data, img, v_homogeneous, jacobian, patch_number, dataset_id] = ...
    get_patch_init(electrodes_num, resolution, dir_dataset, patch_number, number_of_samples);
```

### Data Functions
Handle metadata generation and feature extraction:
```matlab
data = create_csv_dataset(dir_dataset, number_of_samples, number_start_after, ...
    patch_number, number_of_features, save_data_name);
```

### Generate Functions
Work with EIDORS objects and finite element models:
```matlab
model_fwd = create_model(resolution, dimension, z_contact, scale, ...
    shape_function, coverage_ratio, number_virtual_electrodes, ...
    electrodes_number, reinforcement_electrodes);
```

---

## Input/Output Conventions

### Directory Paths
- Always use absolute paths
- Common variables: `dir_dataset`, `dir_function`, `home`

### EIDORS Objects
- `img` - EIDORS image struct
- `fwd_model` - Forward model struct
- `inv_model` - Inverse model struct

### Data Arrays
- Images: `[N × height × width]`
- Voltages: `[N × M measurements]`
- Elements: `[N × Ne elements]`

### Configuration
- Loaded from YAML: `config = load_config('config.yaml')`
- Accessed as struct: `config.model.electrodes_num`

---

## Error Handling Patterns

### File Existence
```matlab
if ~exist(config_file, 'file')
    error('Config file not found: %s', config_file);
end
```

### Try-Catch Blocks
```matlab
try
    data = load(filename);
catch ME
    warning('Failed to load: %s', ME.message);
    data = [];
end
```

### Assertions
```matlab
assert(electrodes_num > 0, 'electrodes_num must be positive');
```
## Dependencies

### MATLAB Toolboxes
- **Required**: None (base MATLAB)
- **Optional**: Signal Processing Toolbox (for some plots)

### External Libraries
- **EIDORS**: Included in `eidors/` directory
- **YAML Parser**: Included in `load_config.m`

### File Format Dependencies
- **HDF5**: Built into MATLAB
- **MAT**: Native MATLAB format

---

## See Also

- [API Reference](API_Reference.md) - Detailed function documentation
- [User Guide](User_Guide.md) - Usage tutorials and examples
- [Development Guide](Development_Guide.md) - Architecture and extension guide
