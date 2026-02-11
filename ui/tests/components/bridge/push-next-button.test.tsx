import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { PushNextButton } from "@/components/bridge/components/push-next-button";
import type { PushNextComponent } from "@/types/bridge";

const component: PushNextComponent = {
  kind: "pushnext",
  label: "Configure Vertical Domain",
  target_window: "atmos_Domain_Vert",
};

describe("PushNextButton", () => {
  it("renders button with label", () => {
    render(<PushNextButton component={component} onNavigate={() => {}} />);
    expect(screen.getByRole("button", { name: "Configure Vertical Domain" })).toBeInTheDocument();
  });

  it("calls onNavigate with target window on click", async () => {
    const onNavigate = vi.fn();
    render(<PushNextButton component={component} onNavigate={onNavigate} />);
    await userEvent.click(screen.getByRole("button"));
    expect(onNavigate).toHaveBeenCalledWith("atmos_Domain_Vert");
  });
});
