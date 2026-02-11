export interface ExperimentResponse {
  readonly id: string;
  readonly owner: string;
  readonly description: string;
  readonly version: string;
  readonly access_list: string;
  readonly privacy: string;
  readonly atmosphere: string;
  readonly ocean: string;
  readonly slab: string;
  readonly mesoscale: string;
}

export interface ExperimentListResponse {
  readonly experiments: readonly ExperimentResponse[];
}

export interface CreateExperimentRequest {
  readonly initial: string;
  readonly description: string;
  readonly privacy?: string;
}

export interface UpdateExperimentRequest {
  readonly description?: string;
  readonly version?: string;
  readonly atmosphere?: string;
  readonly mesoscale?: string;
  readonly ocean?: string;
  readonly slab?: string;
  readonly access_list?: string;
  readonly privacy?: string;
}

export interface CopyExperimentRequest {
  readonly initial: string;
  readonly description: string;
}
