import { describe, it, expect, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import type { ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { useLockStatus, useAcquireLock, useReleaseLock } from "@/hooks/use-locks";

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

describe("useLockStatus", () => {
  it("fetches lock status", async () => {
    const { result } = renderHook(() => useLockStatus("xqgt", "a"), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.locked).toBe(false);
  });
});

describe("useAcquireLock", () => {
  it("acquires a lock", async () => {
    const { result } = renderHook(() => useAcquireLock("xqgt", "a"), { wrapper: createWrapper() });
    result.current.mutate(false);
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.success).toBe(true);
  });
});

describe("useReleaseLock", () => {
  it("releases a lock", async () => {
    const { result } = renderHook(() => useReleaseLock("xqgt", "a"), { wrapper: createWrapper() });
    result.current.mutate();
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.success).toBe(true);
  });
});
