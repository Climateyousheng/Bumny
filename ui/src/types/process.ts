export interface ProcessResponse {
  readonly files: Record<string, string>;
  readonly warnings: readonly string[];
}

export interface SubmitRequest {
  readonly target_host: string;
  readonly target_user: string;
  readonly processed_files: Record<string, string>;
}

export interface SubmitResponse {
  readonly submit_id: string;
  readonly remote_dir: string;
  readonly stdout: string;
  readonly stderr: string;
  readonly exit_status: number;
  readonly success: boolean;
}
