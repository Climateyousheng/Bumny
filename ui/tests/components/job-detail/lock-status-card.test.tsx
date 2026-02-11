import { describe, it, expect, beforeEach } from "vitest";
import { http, HttpResponse } from "msw";
import { server } from "../../mocks/server";
import { renderWithProviders, screen, waitFor } from "../../test-utils";
import { setUsername } from "@/lib/user-store";
import { LockStatusCard } from "@/components/job-detail/lock-status-card";

describe("LockStatusCard", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("shows Available badge when unlocked", async () => {
    renderWithProviders(<LockStatusCard expId="xqgt" jobId="a" />);
    await waitFor(() => {
      expect(screen.getByText("Available")).toBeInTheDocument();
    });
  });

  it("shows Locked badge when locked", async () => {
    server.use(
      http.get("/experiments/:expId/jobs/:jobId/lock", () => {
        return HttpResponse.json({ locked: true, owner: "otheruser" });
      }),
    );
    renderWithProviders(<LockStatusCard expId="xqgt" jobId="a" />);
    await waitFor(() => {
      expect(screen.getByText("Locked")).toBeInTheDocument();
    });
    expect(screen.getByText("by otheruser")).toBeInTheDocument();
  });

  it("shows Acquire Lock button when unlocked", async () => {
    renderWithProviders(<LockStatusCard expId="xqgt" jobId="a" />);
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /acquire lock/i })).toBeInTheDocument();
    });
  });

  it("shows Release Lock button when locked by current user", async () => {
    server.use(
      http.get("/experiments/:expId/jobs/:jobId/lock", () => {
        return HttpResponse.json({ locked: true, owner: "testuser" });
      }),
    );
    renderWithProviders(<LockStatusCard expId="xqgt" jobId="a" />);
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /release lock/i })).toBeInTheDocument();
    });
  });

  it("shows message when locked by another user", async () => {
    server.use(
      http.get("/experiments/:expId/jobs/:jobId/lock", () => {
        return HttpResponse.json({ locked: true, owner: "otheruser" });
      }),
    );
    renderWithProviders(<LockStatusCard expId="xqgt" jobId="a" />);
    await waitFor(() => {
      expect(screen.getByText(/locked by otheruser/i)).toBeInTheDocument();
    });
  });
});
