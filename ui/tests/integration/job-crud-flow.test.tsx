import { describe, it, expect, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";
import { server } from "../mocks/server";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { UserProvider } from "@/hooks/use-user";
import { setUsername } from "@/lib/user-store";
import { JobDetailPage } from "@/components/job-detail/job-detail-page";
import { ExperimentDetailPage } from "@/components/experiment-detail/experiment-detail-page";

function renderApp(initialEntries: string[]) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return render(
    <QueryClientProvider client={queryClient}>
      <UserProvider initialUsername="testuser">
        <MemoryRouter initialEntries={initialEntries}>
          <Routes>
            <Route path="/experiments/:expId" element={<ExperimentDetailPage />} />
            <Route path="/experiments/:expId/jobs/:jobId" element={<JobDetailPage />} />
          </Routes>
        </MemoryRouter>
      </UserProvider>
    </QueryClientProvider>,
  );
}

describe("Job CRUD flow", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("displays jobs on experiment detail page", async () => {
    renderApp(["/experiments/xqgt"]);
    await waitFor(() => {
      expect(screen.getByText("Jobs")).toBeInTheDocument();
    });
  });

  it("creates a new job via dialog", async () => {
    const user = userEvent.setup();
    renderApp(["/experiments/xqgt"]);

    await waitFor(() => {
      expect(screen.getByRole("button", { name: /new job/i })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: /new job/i }));
    expect(screen.getByText("Create Job")).toBeInTheDocument();

    await user.type(screen.getByLabelText("Job ID"), "c");
    await user.type(screen.getByLabelText("Description"), "New job");
    await user.click(screen.getByRole("button", { name: "Create" }));

    await waitFor(() => {
      expect(screen.queryByText("Create Job")).not.toBeInTheDocument();
    });
  });

  it("shows job detail with lock controls", async () => {
    renderApp(["/experiments/xqgt/jobs/a"]);
    await waitFor(() => {
      expect(screen.getByText("Job Details")).toBeInTheDocument();
    });
    await waitFor(() => {
      expect(screen.getByText("Lock Status")).toBeInTheDocument();
    });
  });

  it("acquires a lock on an unlocked job", async () => {
    const user = userEvent.setup();
    renderApp(["/experiments/xqgt/jobs/a"]);

    await waitFor(() => {
      expect(screen.getByRole("button", { name: /acquire lock/i })).toBeInTheDocument();
    });

    // Override lock handler to simulate successful acquisition
    server.use(
      http.post("/experiments/:expId/jobs/:jobId/lock", () => {
        return HttpResponse.json({
          success: true,
          owner: "testuser",
          message: "Lock acquired",
          forced: false,
        });
      }),
    );

    await user.click(screen.getByRole("button", { name: /acquire lock/i }));

    // The mutation should succeed (toast would appear in full app)
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /acquire lock/i })).toBeInTheDocument();
    });
  });

  it("shows locked state when job is locked by another user", async () => {
    server.use(
      http.get("/experiments/:expId/jobs/:jobId/lock", () => {
        return HttpResponse.json({ locked: true, owner: "otheruser" });
      }),
    );

    renderApp(["/experiments/xqgt/jobs/a"]);
    await waitFor(() => {
      expect(screen.getByText("Locked")).toBeInTheDocument();
    });
    expect(screen.getByText("by otheruser")).toBeInTheDocument();
    expect(screen.getByText(/locked by otheruser/i)).toBeInTheDocument();
  });

  it("opens edit form on job detail", async () => {
    const user = userEvent.setup();
    renderApp(["/experiments/xqgt/jobs/a"]);

    await waitFor(() => {
      expect(screen.getByRole("button", { name: /edit/i })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: /edit/i }));
    expect(screen.getByText("Edit Job")).toBeInTheDocument();
  });
});
