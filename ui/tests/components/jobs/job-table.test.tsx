import { describe, it, expect, beforeEach } from "vitest";
import { renderWithProviders, screen } from "../../test-utils";
import { setUsername } from "@/lib/user-store";
import { JobTable } from "@/components/jobs/job-table";
import { buildJob } from "../../mocks/fixtures";

describe("JobTable", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("renders jobs in a table", () => {
    const jobs = [
      buildJob({ job_id: "a", description: "Job A" }),
      buildJob({ job_id: "b", description: "Job B" }),
    ];
    renderWithProviders(<JobTable expId="xqgt" jobs={jobs} />);
    expect(screen.getByText("a")).toBeInTheDocument();
    expect(screen.getByText("b")).toBeInTheDocument();
    expect(screen.getByText("Job A")).toBeInTheDocument();
    expect(screen.getByText("Job B")).toBeInTheDocument();
  });

  it("shows empty state when no jobs", () => {
    renderWithProviders(<JobTable expId="xqgt" jobs={[]} />);
    expect(screen.getByText("No jobs")).toBeInTheDocument();
  });

  it("shows New Job button", () => {
    renderWithProviders(<JobTable expId="xqgt" jobs={[]} />);
    expect(screen.getByRole("button", { name: /new job/i })).toBeInTheDocument();
  });

  it("shows 'Locked by <owner>' when job.opened is non-empty", () => {
    const jobs = [buildJob({ job_id: "a", opened: "nd20983" })];
    renderWithProviders(<JobTable expId="xqgt" jobs={jobs} />);
    expect(screen.getByText("Locked by nd20983")).toBeInTheDocument();
  });

  it("shows 'Available' when job.opened is empty", () => {
    const jobs = [buildJob({ job_id: "a", opened: "" })];
    renderWithProviders(<JobTable expId="xqgt" jobs={jobs} />);
    expect(screen.getByText("Available")).toBeInTheDocument();
  });

  it("shows 'Available' when job.opened is whitespace-only", () => {
    const jobs = [buildJob({ job_id: "a", opened: "   " })];
    renderWithProviders(<JobTable expId="xqgt" jobs={jobs} />);
    expect(screen.getByText("Available")).toBeInTheDocument();
  });
});
