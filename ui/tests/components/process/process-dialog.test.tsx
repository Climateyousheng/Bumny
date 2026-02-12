import { describe, it, expect, vi } from "vitest";
import { renderWithProviders, screen, waitFor, userEvent } from "../../test-utils";
import { ProcessDialog } from "@/components/process/process-dialog";

const defaultProps = {
  expId: "xqjc",
  jobId: "a",
  open: true,
  onOpenChange: vi.fn(),
};

describe("ProcessDialog", () => {
  it("renders the dialog when open", () => {
    renderWithProviders(<ProcessDialog {...defaultProps} />);
    expect(screen.getByText(/Process & Submit: xqjc\/a/)).toBeInTheDocument();
  });

  it("shows Process Job button initially", () => {
    renderWithProviders(<ProcessDialog {...defaultProps} />);
    expect(screen.getByRole("button", { name: /process job/i })).toBeInTheDocument();
  });

  it("processes job and shows file list", async () => {
    renderWithProviders(<ProcessDialog {...defaultProps} />);

    await userEvent.click(screen.getByRole("button", { name: /process job/i }));

    await waitFor(() => {
      expect(screen.getByText("CNTLALL")).toBeInTheDocument();
    });
    expect(screen.getByText("SUBMIT")).toBeInTheDocument();
    expect(screen.getByText("CNTLGEN")).toBeInTheDocument();
  });

  it("shows file preview when clicking a file name", async () => {
    renderWithProviders(<ProcessDialog {...defaultProps} />);

    await userEvent.click(screen.getByRole("button", { name: /process job/i }));

    await waitFor(() => {
      expect(screen.getByText("CNTLALL")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("CNTLALL"));

    expect(screen.getByText(/NLSTCALL/)).toBeInTheDocument();
  });

  it("shows submit form after Continue", async () => {
    renderWithProviders(<ProcessDialog {...defaultProps} />);

    await userEvent.click(screen.getByRole("button", { name: /process job/i }));

    await waitFor(() => {
      expect(screen.getByRole("button", { name: /continue to submit/i })).toBeInTheDocument();
    });

    await userEvent.click(screen.getByRole("button", { name: /continue to submit/i }));

    expect(screen.getByLabelText(/target host/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/username/i)).toBeInTheDocument();
  });

  it("disables submit button until form is filled", async () => {
    renderWithProviders(<ProcessDialog {...defaultProps} />);

    await userEvent.click(screen.getByRole("button", { name: /process job/i }));

    await waitFor(() => {
      expect(screen.getByRole("button", { name: /continue to submit/i })).toBeInTheDocument();
    });

    await userEvent.click(screen.getByRole("button", { name: /continue to submit/i }));

    expect(screen.getByRole("button", { name: /submit to hpc/i })).toBeDisabled();

    await userEvent.type(screen.getByLabelText(/target host/i), "archer2");
    await userEvent.type(screen.getByLabelText(/username/i), "nd20983");

    expect(screen.getByRole("button", { name: /submit to hpc/i })).toBeEnabled();
  });

  it("shows success result after submit", async () => {
    renderWithProviders(<ProcessDialog {...defaultProps} />);

    await userEvent.click(screen.getByRole("button", { name: /process job/i }));
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /continue to submit/i })).toBeInTheDocument();
    });
    await userEvent.click(screen.getByRole("button", { name: /continue to submit/i }));

    await userEvent.type(screen.getByLabelText(/target host/i), "archer2");
    await userEvent.type(screen.getByLabelText(/username/i), "nd20983");
    await userEvent.click(screen.getByRole("button", { name: /submit to hpc/i }));

    await waitFor(() => {
      expect(screen.getByText(/submitted successfully/i)).toBeInTheDocument();
    });
    expect(screen.getByText("03614523")).toBeInTheDocument();
  });
});
