import { describe, it, expect, vi } from "vitest";
import { renderWithProviders, screen, userEvent } from "../../test-utils";
import { MenuBar } from "@/components/layout/menu-bar";

describe("MenuBar", () => {
  it("renders all five menu triggers", () => {
    renderWithProviders(<MenuBar />);
    expect(screen.getByRole("menuitem", { name: "File" })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Search" })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Experiment" })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Job" })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Help" })).toBeInTheDocument();
  });

  it("calls onCreateExperiment when clicking Experiment > New", async () => {
    const onCreateExperiment = vi.fn();
    renderWithProviders(<MenuBar onCreateExperiment={onCreateExperiment} />);

    await userEvent.click(screen.getByRole("menuitem", { name: "Experiment" }));
    await userEvent.click(screen.getByRole("menuitem", { name: /new/i }));

    expect(onCreateExperiment).toHaveBeenCalledOnce();
  });

  it("disables Job > New when not on experiment page", async () => {
    renderWithProviders(<MenuBar />, { initialEntries: ["/"] });

    await userEvent.click(screen.getByRole("menuitem", { name: "Job" }));

    const newJobItem = screen.getByRole("menuitem", { name: /new/i });
    expect(newJobItem).toHaveAttribute("data-disabled");
  });

  it("enables Experiment > Delete on experiment detail route", async () => {
    renderWithProviders(<MenuBar />, { initialEntries: ["/experiments/xqgt"] });

    await userEvent.click(screen.getByRole("menuitem", { name: "Experiment" }));

    const deleteItem = screen.getByRole("menuitem", { name: "Delete" });
    expect(deleteItem).not.toHaveAttribute("data-disabled");
  });

  it("disables Experiment > Delete on root route", async () => {
    renderWithProviders(<MenuBar />, { initialEntries: ["/"] });

    await userEvent.click(screen.getByRole("menuitem", { name: "Experiment" }));

    const deleteItem = screen.getByRole("menuitem", { name: "Delete" });
    expect(deleteItem).toHaveAttribute("data-disabled");
  });

  it("enables Job > New on experiment detail route", async () => {
    renderWithProviders(<MenuBar />, { initialEntries: ["/experiments/xqgt"] });

    await userEvent.click(screen.getByRole("menuitem", { name: "Job" }));

    const newItem = screen.getByRole("menuitem", { name: /new/i });
    expect(newItem).not.toHaveAttribute("data-disabled");
  });

  it("enables Job > Delete on job detail route", async () => {
    renderWithProviders(<MenuBar />, { initialEntries: ["/experiments/xqgt/jobs/a"] });

    await userEvent.click(screen.getByRole("menuitem", { name: "Job" }));

    const deleteItem = screen.getByRole("menuitem", { name: /delete/i });
    expect(deleteItem).not.toHaveAttribute("data-disabled");
  });

  it("disables Job > Delete when not on job route", async () => {
    renderWithProviders(<MenuBar />, { initialEntries: ["/experiments/xqgt"] });

    await userEvent.click(screen.getByRole("menuitem", { name: "Job" }));

    const deleteItem = screen.getByRole("menuitem", { name: /delete/i });
    expect(deleteItem).toHaveAttribute("data-disabled");
  });
});
