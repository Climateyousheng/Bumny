export const queryKeys = {
  experiments: {
    all: ["experiments"] as const,
    detail: (expId: string) => ["experiments", expId] as const,
  },
  jobs: {
    all: (expId: string) => ["experiments", expId, "jobs"] as const,
    detail: (expId: string, jobId: string) => ["experiments", expId, "jobs", jobId] as const,
  },
  locks: {
    detail: (expId: string, jobId: string) => ["experiments", expId, "jobs", jobId, "lock"] as const,
  },
} as const;
