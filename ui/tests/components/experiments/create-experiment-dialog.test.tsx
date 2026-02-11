import { describe, it, expect, beforeEach } from "vitest";
import { renderWithProviders, screen, waitFor, userEvent } from "../../test-utils";
import { setUsername } from "@/lib/user-store";
import { CreateExperimentDialog } from "@/components/experiments/create-experiment-dialog";

describe("CreateExperimentDialog", () => {
  beforeEach(() => {
    setUsername("testuser");
  });

  it("renders the dialog when open", () => {
    renderWithProviders(
      <CreateExperimentDialog open={true} onOpenChange={() => {}} />,
    );
    expect(screen.getByText("Create Experiment")).toBeInTheDocument();
  });

  it("does not render when closed", () => {
    renderWithProviders(
      <CreateExperimentDialog open={false} onOpenChange={() => {}} />,
    );
    expect(screen.queryByText("Create Experiment")).not.toBeInTheDocument();
  });

  it("submits the form and creates an experiment", async () => {
    const user = userEvent.setup();
    let closed = false;
    renderWithProviders(
      <CreateExperimentDialog open={true} onOpenChange={(v) => { closed = !v; }} />,
    );
    await user.type(screen.getByLabelText("Initial Experiment ID"), "test");
    await user.type(screen.getByLabelText("Description"), "Test description");
    await user.click(screen.getByRole("button", { name: "Create" }));
    await waitFor(() => {
      expect(closed).toBe(true);
    });
  });
});
