import { describe, it, expect } from "vitest";
import { renderWithProviders, screen, userEvent, waitFor } from "../../test-utils";
import { MenuBarActions } from "@/components/layout/menu-bar-actions";

describe("MenuBarActions", () => {
  it("opens copy experiment dialog from Experiment menu", async () => {
    renderWithProviders(<MenuBarActions />, {
      initialEntries: ["/experiments/xqgt"],
    });

    await userEvent.click(screen.getByRole("menuitem", { name: "Experiment" }));
    await userEvent.click(screen.getByRole("menuitem", { name: "Copy..." }));

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /copy/i })).toBeInTheDocument();
    });
  });

  it("opens delete experiment dialog from Experiment menu", async () => {
    renderWithProviders(<MenuBarActions />, {
      initialEntries: ["/experiments/xqgt"],
    });

    await userEvent.click(screen.getByRole("menuitem", { name: "Experiment" }));
    await userEvent.click(screen.getByRole("menuitem", { name: "Delete" }));

    await waitFor(() => {
      expect(screen.getByRole("alertdialog")).toBeInTheDocument();
      expect(screen.getByRole("heading", { name: /delete experiment xqgt/i })).toBeInTheDocument();
    });
  });

  it("opens change description dialog from Experiment menu", async () => {
    renderWithProviders(<MenuBarActions />, {
      initialEntries: ["/experiments/xqgt"],
    });

    await userEvent.click(screen.getByRole("menuitem", { name: "Experiment" }));
    await userEvent.click(screen.getByRole("menuitem", { name: "Change description..." }));

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /change description/i })).toBeInTheDocument();
    });
  });

  it("opens change privacy dialog from Experiment menu", async () => {
    renderWithProviders(<MenuBarActions />, {
      initialEntries: ["/experiments/xqgt"],
    });

    await userEvent.click(screen.getByRole("menuitem", { name: "Experiment" }));
    await userEvent.click(screen.getByRole("menuitem", { name: "Change privacy..." }));

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /privacy/i })).toBeInTheDocument();
    });
  });

  it("opens force close dialog from Job menu", async () => {
    renderWithProviders(<MenuBarActions />, {
      initialEntries: ["/experiments/xqgt/jobs/a"],
    });

    await userEvent.click(screen.getByRole("menuitem", { name: "Job" }));
    await userEvent.click(screen.getByRole("menuitem", { name: "Force Close..." }));

    await waitFor(() => {
      expect(screen.getByRole("alertdialog")).toBeInTheDocument();
      expect(screen.getByRole("heading", { name: /force close job a/i })).toBeInTheDocument();
    });
  });

  it("does not render experiment dialogs when no experiment is selected", () => {
    renderWithProviders(<MenuBarActions />, {
      initialEntries: ["/"],
    });

    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });
});
