import { describe, it, expect, beforeEach } from "vitest";
import { renderWithProviders, screen, waitFor } from "../../test-utils";
import { setUsername } from "@/lib/user-store";
import { ExperimentListPage } from "@/components/experiments/experiment-list-page";

describe("ExperimentListPage", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("renders the experiment list heading", async () => {
    renderWithProviders(<ExperimentListPage />);
    await waitFor(() => {
      expect(screen.getByText("Experiments")).toBeInTheDocument();
    });
  });

  it("displays experiments from the API", async () => {
    renderWithProviders(<ExperimentListPage />);
    await waitFor(() => {
      expect(screen.getByText("aaaa")).toBeInTheDocument();
    });
    expect(screen.getByText("xqgt")).toBeInTheDocument();
    expect(screen.getByText("xqjc")).toBeInTheDocument();
  });

  it("filters experiments by search", async () => {
    const { default: userEvent } = await import("@testing-library/user-event");
    const user = userEvent.setup();
    renderWithProviders(<ExperimentListPage />);
    await waitFor(() => {
      expect(screen.getByText("aaaa")).toBeInTheDocument();
    });
    await user.type(screen.getByLabelText("Search"), "control");
    expect(screen.queryByText("aaaa")).not.toBeInTheDocument();
    expect(screen.getByText("xqgt")).toBeInTheDocument();
  });

  it("shows New Experiment button", async () => {
    renderWithProviders(<ExperimentListPage />);
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /new experiment/i })).toBeInTheDocument();
    });
  });
});
