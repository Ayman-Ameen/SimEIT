# SimEIT documentation overview

This document summarizes the core modules, data flow, and key parameters of the SimEIT framework contained in this repository.

## High-level flow
1. generate_dataset.m
  - Adds required paths (`plots`, `generate_functions`, `data_functions`, `experiemental`)
  - Loads configuration via `data_functions/load_config.m`
  - Initializes or resumes dataset state (`generate_functions/get_patch_init.m`)
   - Runs experimental or simulation pipeline depending on `config.general.mode`
   - Saves outputs per patch under `dataset/MAT/<electrodes_num>/`

2. get_patch_init.m
   - Prepares homogeneous model and Jacobian with EIDORS
   - Tracks dataset indices, samples per patch, and feature counts
  - Prepares CSV metadata (`data_functions/create_csv_dataset.m`)

3. create_csv_dataset.m
   - Generates per-sample metadata and random features
  - Uses `data_functions/features_parameters.m` to sample non-intersecting shapes
   - Logs conductivity, types, features, and coverage area

4. generate_patch.m
   - Computes per-sample element data and forward solutions
   - Builds pixel images and differential voltages
   - Optionally handles electrode contact resistance

## Key modules
- generate_dataset.m: Top-level driver
- data_functions/
  - load_config.m: Simple YAML config reader
  - create_csv_dataset.m: Dataset CSV and feature generation
  - features_parameters.m: Non-overlapping object placement
  - get_random_values_within_range.m: Conductivity sampling (log-space)
- generate_functions/
  - create_model.m, electrodes_nodes.m: Mesh/electrodes generation
  - generate_patch.m: Forward solver for a batch of samples
  - forward_solver_for_one_sample.m: Physics step
  - get_patch_init.m: Homogeneous model, Jacobian, IDs
  - set_electrodes_resistance.m, get_electrodes_resistance.m: Optional contact resistance
- experiemental/
  - get_experimental_data.m: Load measured voltages and camera masks

## Configuration bindings
- Mode, electrodes_num, resolution, and dataset sizes are read from `config.yaml` in `generate_dataset.m`.
- Additional parameters (e.g., geometry and conductivity ranges) can be progressively propagated to downstream functions if needed.

## Data structures
- data (simulation)
  - number_of_objects: N x 1
  - type: N x max_objects cell
  - features: N x (max_objects * features_per_object)
  - conductivity: N x max_objects
- data (experimental)
  - measurements: B x 2 x E^2
  - images: B x 2 x H x W (binary masks)

## Extending
- To add new shapes: extend `Data_functions/object2str.m` and include the new shape name in `config.dataset.object_types`.
- To modify conductivity distributions: update `get_random_values_within_range.m` or bind more config fields.
- To support HDF5 saving: use `generate_functions/save_hdf5.m` and enable in `config.yaml`.