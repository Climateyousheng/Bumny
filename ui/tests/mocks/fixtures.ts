import type { ExperimentResponse } from "@/types/experiment";
import type { JobResponse } from "@/types/job";
import type { LockStatusResponse, LockResultResponse } from "@/types/lock";

export function buildExperiment(overrides: Partial<ExperimentResponse> = {}): ExperimentResponse {
  return {
    id: "xqgt",
    owner: "nd20983",
    description: "Test experiment",
    version: "8.6",
    access_list: "",
    privacy: "N",
    atmosphere: "",
    ocean: "",
    slab: "",
    mesoscale: "",
    ...overrides,
  };
}

export function buildJob(overrides: Partial<JobResponse> = {}): JobResponse {
  return {
    job_id: "a",
    exp_id: "xqgt",
    version: "8.6",
    description: "Test job",
    opened: "",
    atmosphere: "",
    ocean: "",
    slab: "",
    mesoscale: "",
    ...overrides,
  };
}

export function buildLockStatus(overrides: Partial<LockStatusResponse> = {}): LockStatusResponse {
  return {
    locked: false,
    owner: null,
    ...overrides,
  };
}

export function buildLockResult(overrides: Partial<LockResultResponse> = {}): LockResultResponse {
  return {
    success: true,
    owner: "nd20983",
    message: "Lock acquired",
    forced: false,
    ...overrides,
  };
}
