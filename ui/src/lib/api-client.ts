import { ApiError } from "@/types/api";
import type { BasisRawResponse } from "@/types/basis";
import type { NavNodeResponse, WindowResponse, HelpResponse, VariableRegistrationResponse, PartitionResponse, VariablesResponse } from "@/types/bridge";
import type { ExperimentListResponse, ExperimentResponse, CreateExperimentRequest, UpdateExperimentRequest, CopyExperimentRequest } from "@/types/experiment";
import type { JobListResponse, JobResponse, CreateJobRequest, UpdateJobRequest, CopyJobRequest } from "@/types/job";
import type { LockStatusResponse, LockResultResponse } from "@/types/lock";
import { getUsername } from "@/lib/user-store";

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const res = await fetch(path, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...options.headers,
    },
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({ detail: res.statusText }));
    throw new ApiError(res.status, (body as { detail?: string }).detail ?? res.statusText);
  }

  if (res.status === 204) return undefined as T;
  return res.json() as Promise<T>;
}

function requireUser(): string {
  const username = getUsername();
  if (!username) throw new Error("Username is required");
  return username;
}

function userHeaders(): Record<string, string> {
  return { "X-UMUI-User": requireUser() };
}

// --- Experiments ---

export function listExperiments(): Promise<ExperimentListResponse> {
  return request("/experiments");
}

export function getExperiment(expId: string): Promise<ExperimentResponse> {
  return request(`/experiments/${expId}`);
}

export function createExperiment(body: CreateExperimentRequest): Promise<ExperimentResponse> {
  return request("/experiments", {
    method: "POST",
    headers: userHeaders(),
    body: JSON.stringify(body),
  });
}

export function updateExperiment(expId: string, body: UpdateExperimentRequest): Promise<ExperimentResponse> {
  return request(`/experiments/${expId}`, {
    method: "PATCH",
    headers: userHeaders(),
    body: JSON.stringify(body),
  });
}

export function deleteExperiment(expId: string): Promise<void> {
  return request(`/experiments/${expId}`, {
    method: "DELETE",
    headers: userHeaders(),
  });
}

export function copyExperiment(expId: string, body: CopyExperimentRequest): Promise<ExperimentResponse> {
  return request(`/experiments/${expId}/copy`, {
    method: "POST",
    headers: userHeaders(),
    body: JSON.stringify(body),
  });
}

// --- Jobs ---

export function listJobs(expId: string): Promise<JobListResponse> {
  return request(`/experiments/${expId}/jobs`);
}

export function getJob(expId: string, jobId: string): Promise<JobResponse> {
  return request(`/experiments/${expId}/jobs/${jobId}`);
}

export function createJob(expId: string, body: CreateJobRequest): Promise<JobResponse> {
  return request(`/experiments/${expId}/jobs`, {
    method: "POST",
    headers: userHeaders(),
    body: JSON.stringify(body),
  });
}

export function updateJob(expId: string, jobId: string, body: UpdateJobRequest): Promise<JobResponse> {
  return request(`/experiments/${expId}/jobs/${jobId}`, {
    method: "PATCH",
    headers: userHeaders(),
    body: JSON.stringify(body),
  });
}

export function deleteJob(expId: string, jobId: string): Promise<void> {
  return request(`/experiments/${expId}/jobs/${jobId}`, {
    method: "DELETE",
    headers: userHeaders(),
  });
}

export function copyJob(expId: string, jobId: string, body: CopyJobRequest): Promise<JobResponse> {
  return request(`/experiments/${expId}/jobs/${jobId}/copy`, {
    method: "POST",
    headers: userHeaders(),
    body: JSON.stringify(body),
  });
}

// --- Locks ---

export function checkLock(expId: string, jobId: string): Promise<LockStatusResponse> {
  return request(`/experiments/${expId}/jobs/${jobId}/lock`);
}

export function acquireLock(expId: string, jobId: string, force = false): Promise<LockResultResponse> {
  return request(`/experiments/${expId}/jobs/${jobId}/lock`, {
    method: "POST",
    headers: userHeaders(),
    body: JSON.stringify({ force }),
  });
}

export function releaseLock(expId: string, jobId: string): Promise<LockResultResponse> {
  return request(`/experiments/${expId}/jobs/${jobId}/lock`, {
    method: "DELETE",
    headers: userHeaders(),
  });
}

// --- Bridge ---

export function getNavTree(): Promise<NavNodeResponse[]> {
  return request("/bridge/nav");
}

export function getWindow(winId: string, expId?: string, jobId?: string): Promise<WindowResponse> {
  const params = new URLSearchParams();
  if (expId) params.set("exp_id", expId);
  if (jobId) params.set("job_id", jobId);
  const qs = params.toString();
  return request(`/bridge/windows/${winId}${qs ? `?${qs}` : ""}`);
}

export function getWindowHelp(winId: string): Promise<HelpResponse> {
  return request(`/bridge/windows/${winId}/help`);
}

export function getRegister(): Promise<VariableRegistrationResponse[]> {
  return request("/bridge/register");
}

export function getPartitions(): Promise<PartitionResponse[]> {
  return request("/bridge/partitions");
}

export function getJobVariables(expId: string, jobId: string): Promise<VariablesResponse> {
  return request(`/bridge/variables/${expId}/${jobId}`);
}

export function getBasisRaw(expId: string, jobId: string): Promise<BasisRawResponse> {
  return request(`/bridge/basis/${expId}/${jobId}/raw`);
}

export function getWindowVariables(expId: string, jobId: string, winId: string): Promise<VariablesResponse> {
  return request(`/bridge/variables/${expId}/${jobId}/${winId}`);
}

export function updateBridgeVariables(
  expId: string,
  jobId: string,
  variables: Record<string, string | string[]>,
): Promise<VariablesResponse> {
  return request(`/bridge/variables/${expId}/${jobId}`, {
    method: "PATCH",
    headers: userHeaders(),
    body: JSON.stringify({ variables }),
  });
}
