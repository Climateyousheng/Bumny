export interface LockStatusResponse {
  readonly locked: boolean;
  readonly owner: string | null;
}

export interface AcquireLockRequest {
  readonly force?: boolean;
}

export interface LockResultResponse {
  readonly success: boolean;
  readonly owner: string;
  readonly message: string;
  readonly forced?: boolean;
}
