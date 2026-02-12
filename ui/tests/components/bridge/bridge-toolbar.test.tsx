import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { BridgeToolbar } from "@/components/bridge/bridge-toolbar";

const defaultProps = {
  lockStatus: { locked: false, owner: null },
  isEditing: false,
  isDirty: false,
  isSaving: false,
  isAcquiring: false,
  onStartEditing: vi.fn(),
  onStopEditing: vi.fn(),
  onSave: vi.fn(),
  onReset: vi.fn(),
};

describe("BridgeToolbar", () => {
  it("shows 'Available' badge when unlocked", () => {
    render(<BridgeToolbar {...defaultProps} />);
    expect(screen.getByText("Available")).toBeInTheDocument();
  });

  it("shows 'Locked by <owner>' badge when locked", () => {
    render(
      <BridgeToolbar
        {...defaultProps}
        lockStatus={{ locked: true, owner: "nd20983" }}
      />,
    );
    expect(screen.getByText(/Locked by nd20983/)).toBeInTheDocument();
  });

  it("shows 'Start Editing' button when not editing", () => {
    render(<BridgeToolbar {...defaultProps} />);
    expect(screen.getByRole("button", { name: /start editing/i })).toBeInTheDocument();
  });

  it("calls onStartEditing when Start Editing is clicked", async () => {
    const onStartEditing = vi.fn().mockResolvedValue(undefined);
    render(<BridgeToolbar {...defaultProps} onStartEditing={onStartEditing} />);

    await userEvent.click(screen.getByRole("button", { name: /start editing/i }));
    expect(onStartEditing).toHaveBeenCalledOnce();
  });

  it("shows Save, Reset, Stop Editing when editing", () => {
    render(<BridgeToolbar {...defaultProps} isEditing={true} />);
    expect(screen.getByRole("button", { name: /save/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /reset/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /stop editing/i })).toBeInTheDocument();
  });

  it("disables Save when not dirty", () => {
    render(<BridgeToolbar {...defaultProps} isEditing={true} isDirty={false} />);
    expect(screen.getByRole("button", { name: /save/i })).toBeDisabled();
  });

  it("enables Save when dirty", () => {
    render(<BridgeToolbar {...defaultProps} isEditing={true} isDirty={true} />);
    expect(screen.getByRole("button", { name: /save/i })).toBeEnabled();
  });

  it("shows force acquire dialog when locked by another user", async () => {
    const onStartEditing = vi.fn().mockResolvedValue(undefined);
    render(
      <BridgeToolbar
        {...defaultProps}
        lockStatus={{ locked: true, owner: "otheruser" }}
        onStartEditing={onStartEditing}
      />,
    );

    await userEvent.click(screen.getByRole("button", { name: /start editing/i }));

    expect(screen.getByText(/force acquire lock/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /force acquire/i })).toBeInTheDocument();
  });

  it("shows disabled Process button", () => {
    render(<BridgeToolbar {...defaultProps} />);
    expect(screen.getByRole("button", { name: /process/i })).toBeDisabled();
  });

  it("shows disabled Submit button", () => {
    render(<BridgeToolbar {...defaultProps} />);
    expect(screen.getByRole("button", { name: /submit/i })).toBeDisabled();
  });

  it("calls onStartEditing with force when Force Acquire is confirmed", async () => {
    const onStartEditing = vi.fn().mockResolvedValue(undefined);
    render(
      <BridgeToolbar
        {...defaultProps}
        lockStatus={{ locked: true, owner: "otheruser" }}
        onStartEditing={onStartEditing}
      />,
    );

    await userEvent.click(screen.getByRole("button", { name: /start editing/i }));
    await userEvent.click(screen.getByRole("button", { name: /force acquire/i }));

    expect(onStartEditing).toHaveBeenCalledWith(true);
  });
});
