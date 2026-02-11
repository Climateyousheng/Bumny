import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import type { ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { MemoryRouter } from "react-router-dom";
import { UserProvider } from "@/hooks/use-user";
import { UserPromptDialog } from "@/components/layout/user-prompt-dialog";

function wrapper(initialUsername?: string) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return function Wrapper({ children }: { readonly children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <UserProvider initialUsername={initialUsername}>
          <MemoryRouter>{children}</MemoryRouter>
        </UserProvider>
      </QueryClientProvider>
    );
  };
}

describe("UserPromptDialog", () => {
  it("shows dialog when no username is set", () => {
    render(<UserPromptDialog />, { wrapper: wrapper("") });
    expect(screen.getByText("Welcome to UMUI")).toBeInTheDocument();
  });

  it("does not show dialog when username is set", () => {
    render(<UserPromptDialog />, { wrapper: wrapper("nd20983") });
    expect(screen.queryByText("Welcome to UMUI")).not.toBeInTheDocument();
  });

  it("validates empty username", async () => {
    const user = userEvent.setup();
    render(<UserPromptDialog />, { wrapper: wrapper("") });
    await user.click(screen.getByRole("button", { name: "Continue" }));
    expect(screen.getByText("Username is required")).toBeInTheDocument();
  });

  it("validates invalid characters", async () => {
    const user = userEvent.setup();
    render(<UserPromptDialog />, { wrapper: wrapper("") });
    await user.type(screen.getByLabelText("Username"), "user name!");
    await user.click(screen.getByRole("button", { name: "Continue" }));
    expect(screen.getByText("Username must be alphanumeric (underscores allowed)")).toBeInTheDocument();
  });

  it("accepts valid username and closes dialog", async () => {
    const user = userEvent.setup();
    render(<UserPromptDialog />, { wrapper: wrapper("") });
    await user.type(screen.getByLabelText("Username"), "nd20983");
    await user.click(screen.getByRole("button", { name: "Continue" }));
    expect(screen.queryByText("Welcome to UMUI")).not.toBeInTheDocument();
  });
});
