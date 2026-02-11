export interface JobResponse {
  readonly job_id: string;
  readonly exp_id: string;
  readonly version: string;
  readonly description: string;
  readonly opened: string;
  readonly atmosphere: string;
  readonly ocean: string;
  readonly slab: string;
  readonly mesoscale: string;
}

export interface JobListResponse {
  readonly jobs: readonly JobResponse[];
}

export interface CreateJobRequest {
  readonly job_id: string;
  readonly description?: string;
  readonly version?: string;
}

export interface UpdateJobRequest {
  readonly description?: string;
  readonly version?: string;
  readonly atmosphere?: string;
  readonly ocean?: string;
  readonly slab?: string;
  readonly mesoscale?: string;
}

export interface CopyJobRequest {
  readonly dest_exp_id: string;
  readonly dest_job_id: string;
  readonly description?: string;
}
