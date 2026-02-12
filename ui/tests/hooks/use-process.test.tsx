import { describe, it, expect, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import type { ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { useProcessJob, useSubmitJob } from "@/hooks/use-process";

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return function Wrapper({ children }: { readonly children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <UserProvider initialUsername="testuser">{children}</UserProvider>
      </QueryClientProvider>
    );
  };
}

beforeEach(() => {
  setUsername("testuser");
});

describe("useProcessJob", () => {
  it("processes a job and returns files", async () => {
    const { result } = renderHook(() => useProcessJob(), { wrapper: createWrapper() });
    result.current.mutate({ expId: "xqjc", jobId: "a" });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.files).toHaveProperty("CNTLALL");
    expect(result.current.data?.files).toHaveProperty("SUBMIT");
    expect(result.current.data?.warnings).toEqual([]);
  });
});

describe("useSubmitJob", () => {
  it("submits a job and returns result", async () => {
    const { result } = renderHook(() => useSubmitJob(), { wrapper: createWrapper() });
    result.current.mutate({
      expId: "xqjc",
      jobId: "a",
      request: {
        target_host: "archer2",
        target_user: "nd20983",
        processed_files: { SUBMIT: "#!/bin/ksh\necho done" },
      },
    });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.success).toBe(true);
    expect(result.current.data?.submit_id).toBe("03614523");
  });
});
