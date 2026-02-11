import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ErrorAlert } from "@/components/shared/error-alert";

describe("ErrorAlert", () => {
  it("renders the error message", () => {
    render(<ErrorAlert message="Something went wrong" />);
    expect(screen.getByRole("alert")).toBeInTheDocument();
    expect(screen.getByText("Something went wrong")).toBeInTheDocument();
  });
});
