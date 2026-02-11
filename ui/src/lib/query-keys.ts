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
  bridge: {
    nav: ["bridge", "nav"] as const,
    window: (winId: string, expId?: string, jobId?: string) =>
      ["bridge", "windows", winId, expId ?? "", jobId ?? ""] as const,
    windowHelp: (winId: string) => ["bridge", "windows", winId, "help"] as const,
    register: ["bridge", "register"] as const,
    partitions: ["bridge", "partitions"] as const,
    windowVariables: (expId: string, jobId: string, winId: string) =>
      ["bridge", "variables", expId, jobId, winId] as const,
  },
} as const;
