function [conductivity] = get_random_values_within_range(number_of_samples, max_number_of_objects, maximum_conductivity, minimum_conductivity, maximum_variation)
%GET_RANDOM_VALUES_WITHIN_RANGE Generate log-uniform random values per sample/object.
%   conductivity = GET_RANDOM_VALUES_WITHIN_RANGE(number_of_samples, max_number_of_objects,
%       maximum_conductivity, minimum_conductivity, maximum_variation)
%
%   Generates values that are uniformly distributed in log-space, using a
%   per-sample base range with limited per-object variation.
%
%   Inputs:
%     number_of_samples      - Number of samples to generate.
%     max_number_of_objects  - Number of objects (columns) per sample.
%     maximum_conductivity   - Upper bound of the value range (linear scale).
%     minimum_conductivity   - Lower bound of the value range (linear scale).
%     maximum_variation      - Controls the per-object variation around each sample's base.
%
%   Output:
%     conductivity           - [number_of_samples x max_number_of_objects] values.

log_maximum_conductivity = log10(maximum_conductivity) / (maximum_variation * 3);
log_minimum_conductivity = log10(minimum_conductivity) / (maximum_variation * 3);
conductivity_log_one_sample = log_minimum_conductivity + ((log_maximum_conductivity - log_minimum_conductivity) * rand([number_of_samples, 1]));
conductivity_log_one_sample = repmat(conductivity_log_one_sample, 1, max_number_of_objects);
conductivity_log = conductivity_log_one_sample + ((conductivity_log_one_sample - maximum_variation * conductivity_log_one_sample) .* rand([number_of_samples, max_number_of_objects]));
conductivity = 10.^(conductivity_log);
end