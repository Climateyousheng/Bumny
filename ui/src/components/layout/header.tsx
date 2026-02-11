import { Link } from "react-router-dom";
import { useUser } from "@/hooks/use-user";
import { User } from "lucide-react";

export function Header() {
  const { username } = useUser();

  return (
    <header className="border-b">
      <div className="container flex h-14 items-center justify-between">
        <nav className="flex items-center gap-6">
          <Link to="/" className="text-lg font-bold">
            UMUI
          </Link>
          <Link to="/" className="text-sm text-muted-foreground hover:text-foreground">
            Experiments
          </Link>
        </nav>
        {username && (
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <User className="h-4 w-4" />
            <span>{username}</span>
          </div>
        )}
      </div>
    </header>
  );
}
