import { Outlet } from "react-router-dom";
import { Header } from "./header";
import { UserPromptDialog } from "./user-prompt-dialog";
import { Toaster } from "sonner";

export function AppShell() {
  return (
    <div className="min-h-screen">
      <Header />
      <main className="container py-6">
        <Outlet />
      </main>
      <UserPromptDialog />
      <Toaster />
    </div>
  );
}
