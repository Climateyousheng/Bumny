import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { BasisViewer } from "@/components/basis/basis-viewer";

const SAMPLE_CONTENT = " &NLSTCALL\n OCAAA=1\n &END\n";

describe("BasisViewer", () => {
  it("renders content in a read-only textarea", () => {
    render(<BasisViewer content={SAMPLE_CONTENT} lineCount={3} />);

    const textarea = screen.getByLabelText("Basis file content");
    expect(textarea).toBeInTheDocument();
    expect(textarea).toHaveAttribute("readonly");
    expect(textarea).toHaveValue(SAMPLE_CONTENT);
  });

  it("shows line count", () => {
    render(<BasisViewer content={SAMPLE_CONTENT} lineCount={27321} />);

    expect(screen.getByText("27,321 lines")).toBeInTheDocument();
  });

  it("shows loading skeleton when loading", () => {
    render(<BasisViewer content="" lineCount={0} loading />);

    expect(screen.queryByLabelText("Basis file content")).not.toBeInTheDocument();
  });

  it("copies content to clipboard on click", async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.assign(navigator, { clipboard: { writeText } });

    render(<BasisViewer content={SAMPLE_CONTENT} lineCount={3} />);

    await userEvent.click(screen.getByRole("button", { name: /copy/i }));

    expect(writeText).toHaveBeenCalledWith(SAMPLE_CONTENT);
    expect(screen.getByText("Copied")).toBeInTheDocument();
  });
});
