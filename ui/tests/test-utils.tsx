import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, type RenderOptions } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import type { ReactElement, ReactNode } from "react";
import { UserProvider } from "@/hooks/use-user";

function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: 0,
      },
      mutations: {
        retry: false,
      },
    },
  });
}

interface WrapperProps {
  readonly children: ReactNode;
  readonly initialEntries?: string[];
  readonly username?: string;
}

function TestWrapper({ children, initialEntries = ["/"], username = "testuser" }: WrapperProps) {
  const queryClient = createTestQueryClient();
  return (
    <QueryClientProvider client={queryClient}>
      <UserProvider initialUsername={username}>
        <MemoryRouter initialEntries={initialEntries}>
          {children}
        </MemoryRouter>
      </UserProvider>
    </QueryClientProvider>
  );
}

interface CustomRenderOptions extends Omit<RenderOptions, "wrapper"> {
  readonly initialEntries?: string[];
  readonly username?: string;
}

export function renderWithProviders(
  ui: ReactElement,
  options: CustomRenderOptions = {},
) {
  const { initialEntries, username, ...renderOptions } = options;
  return render(ui, {
    wrapper: ({ children }: { readonly children: ReactNode }) => (
      <TestWrapper initialEntries={initialEntries} username={username}>
        {children}
      </TestWrapper>
    ),
    ...renderOptions,
  });
}

export { createTestQueryClient };
export { default as userEvent } from "@testing-library/user-event";
export { screen, waitFor, within } from "@testing-library/react";
