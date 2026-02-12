import { describe, it, expect, beforeEach } from "vitest";
import { renderWithProviders, screen, userEvent } from "../../test-utils";
import { setUsername } from "@/lib/user-store";
import { JobRowActions } from "@/components/jobs/job-row-actions";
import { buildJob } from "../../mocks/fixtures";

describe("JobRowActions", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("renders Open Bridge link in dropdown", async () => {
    const job = buildJob({ job_id: "a", exp_id: "xqgt" });
    renderWithProviders(<JobRowActions expId="xqgt" job={job} />);

    await userEvent.click(screen.getByRole("button", { name: /actions/i }));

    const link = screen.getByRole("menuitem", { name: /open bridge/i });
    expect(link).toBeInTheDocument();
    expect(link.closest("a")).toHaveAttribute("href", "/experiments/xqgt/jobs/a/bridge");
  });

  it("renders Copy and Delete actions", async () => {
    const job = buildJob({ job_id: "a", exp_id: "xqgt" });
    renderWithProviders(<JobRowActions expId="xqgt" job={job} />);

    await userEvent.click(screen.getByRole("button", { name: /actions/i }));

    expect(screen.getByRole("menuitem", { name: /copy/i })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: /delete/i })).toBeInTheDocument();
  });
});
