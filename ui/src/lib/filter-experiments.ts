import type { ExperimentResponse } from "@/types/experiment";

export interface ExplorerFilters {
  readonly search: string;
  readonly owner: string;
  readonly version: string;
  readonly privacy: string;
}

export const EMPTY_FILTERS: ExplorerFilters = {
  search: "",
  owner: "",
  version: "",
  privacy: "",
};

export function filterExperiments(
  experiments: readonly ExperimentResponse[],
  filters: ExplorerFilters,
): readonly ExperimentResponse[] {
  return experiments.filter((exp) => {
    if (filters.search) {
      const q = filters.search.toLowerCase();
      if (
        !exp.id.toLowerCase().includes(q) &&
        !exp.owner.toLowerCase().includes(q) &&
        !exp.description.toLowerCase().includes(q)
      ) {
        return false;
      }
    }
    if (filters.owner && exp.owner !== filters.owner) return false;
    if (filters.version && exp.version !== filters.version) return false;
    if (filters.privacy && exp.privacy !== filters.privacy) return false;
    return true;
  });
}
