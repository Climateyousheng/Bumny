import { describe, it, expect, beforeEach } from "vitest";
import { renderHook, waitFor, act } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { MemoryRouter } from "react-router-dom";
import type { ReactNode } from "react";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { useBridgeEdit } from "@/hooks/use-bridge-edit";

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  });
  return function Wrapper({ children }: { readonly children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <UserProvider initialUsername="testuser">
          <MemoryRouter>{children}</MemoryRouter>
        </UserProvider>
      </QueryClientProvider>
    );
  };
}

describe("useBridgeEdit", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("starts with isEditing=false and no draft changes", () => {
    const { result } = renderHook(() => useBridgeEdit("xqgt", "a"), {
      wrapper: createWrapper(),
    });

    expect(result.current.isEditing).toBe(false);
    expect(result.current.isDirty).toBe(false);
    expect(result.current.draftChanges).toEqual({});
  });

  it("updateDraft adds changes immutably", () => {
    const { result } = renderHook(() => useBridgeEdit("xqgt", "a"), {
      wrapper: createWrapper(),
    });

    act(() => {
      result.current.updateDraft("NCOLSAG", "192");
    });

    expect(result.current.draftChanges).toEqual({ NCOLSAG: "192" });
    expect(result.current.isDirty).toBe(true);
  });

  it("updateDraftArray updates a specific index", () => {
    const { result } = renderHook(() => useBridgeEdit("xqgt", "a"), {
      wrapper: createWrapper(),
    });

    act(() => {
      result.current.updateDraftArray("COL1", 0, "val0");
      result.current.updateDraftArray("COL1", 2, "val2");
    });

    const arr = result.current.draftChanges["COL1"];
    expect(Array.isArray(arr)).toBe(true);
    expect(arr).toEqual(expect.arrayContaining(["val0"]));
  });

  it("resetDraft clears all changes", () => {
    const { result } = renderHook(() => useBridgeEdit("xqgt", "a"), {
      wrapper: createWrapper(),
    });

    act(() => {
      result.current.updateDraft("NCOLSAG", "192");
    });
    expect(result.current.isDirty).toBe(true);

    act(() => {
      result.current.resetDraft();
    });
    expect(result.current.isDirty).toBe(false);
    expect(result.current.draftChanges).toEqual({});
  });

  it("mergeVariables overlays draft on server vars", () => {
    const { result } = renderHook(() => useBridgeEdit("xqgt", "a"), {
      wrapper: createWrapper(),
    });

    act(() => {
      result.current.updateDraft("NCOLSAG", "192");
    });

    const merged = result.current.mergeVariables({ OCAAA: "1", NCOLSAG: "96" });
    expect(merged).toEqual({ OCAAA: "1", NCOLSAG: "192" });
  });

  it("startEditing acquires lock and sets editing mode", async () => {
    const { result } = renderHook(() => useBridgeEdit("xqgt", "a"), {
      wrapper: createWrapper(),
    });

    await act(async () => {
      await result.current.startEditing();
    });

    expect(result.current.isEditing).toBe(true);
  });

  it("save calls PATCH endpoint and clears draft on success", async () => {
    const { result } = renderHook(() => useBridgeEdit("xqgt", "a"), {
      wrapper: createWrapper(),
    });

    act(() => {
      result.current.updateDraft("NCOLSAG", "192");
    });

    await act(async () => {
      await result.current.save();
    });

    await waitFor(() => {
      expect(result.current.isDirty).toBe(false);
    });
  });
});
