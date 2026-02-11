import { describe, it, expect } from "vitest";
import { renderHook, act } from "@testing-library/react";
import type { ReactNode } from "react";
import { UserProvider, useUser } from "@/hooks/use-user";

function wrapper({ children }: { readonly children: ReactNode }) {
  return <UserProvider initialUsername="testuser">{children}</UserProvider>;
}

describe("useUser", () => {
  it("provides the initial username", () => {
    const { result } = renderHook(() => useUser(), { wrapper });
    expect(result.current.username).toBe("testuser");
  });

  it("allows setting the username", () => {
    const { result } = renderHook(() => useUser(), { wrapper });
    act(() => {
      result.current.setUsername("newuser");
    });
    expect(result.current.username).toBe("newuser");
  });

  it("persists username to localStorage", () => {
    const { result } = renderHook(() => useUser(), { wrapper });
    act(() => {
      result.current.setUsername("stored");
    });
    expect(localStorage.getItem("umui-username")).toBe("stored");
  });

  it("throws when used outside provider", () => {
    expect(() => {
      renderHook(() => useUser());
    }).toThrow("useUser must be used within a UserProvider");
  });
});
