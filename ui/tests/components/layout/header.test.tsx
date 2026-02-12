import { describe, it, expect } from "vitest";
import { renderWithProviders, screen } from "../../test-utils";
import { Header } from "@/components/layout/header";

describe("Header", () => {

  it("renders the UMUI brand link", () => {
    renderWithProviders(<Header />);
    expect(screen.getByText("UMUI")).toBeInTheDocument();
  });

  it("renders the menubar with File menu", () => {
    renderWithProviders(<Header />);
    expect(screen.getByRole("menuitem", { name: "File" })).toBeInTheDocument();
  });

  it("displays the current username", () => {
    renderWithProviders(<Header />, { username: "nd20983" });
    expect(screen.getByText("nd20983")).toBeInTheDocument();
  });

  it("does not display username when empty", () => {
    renderWithProviders(<Header />, { username: "" });
    expect(screen.queryByText("nd20983")).not.toBeInTheDocument();
  });
});
