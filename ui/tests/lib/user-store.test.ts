import { describe, it, expect, beforeEach } from "vitest";
import { getUsername, setUsername, clearUsername } from "@/lib/user-store";

describe("user-store", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("returns empty string when no username is stored", () => {
    expect(getUsername()).toBe("");
  });

  it("stores and retrieves a username", () => {
    setUsername("nd20983");
    expect(getUsername()).toBe("nd20983");
  });

  it("overwrites existing username", () => {
    setUsername("user1");
    setUsername("user2");
    expect(getUsername()).toBe("user2");
  });

  it("clears the username", () => {
    setUsername("nd20983");
    clearUsername();
    expect(getUsername()).toBe("");
  });

  it("uses the correct localStorage key", () => {
    setUsername("nd20983");
    expect(localStorage.getItem("umui-username")).toBe("nd20983");
  });
});
