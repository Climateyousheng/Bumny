import { useQueryClient } from "@tanstack/react-query";
import { useLocation } from "react-router-dom";
import {
  Menubar,
  MenubarContent,
  MenubarItem,
  MenubarMenu,
  MenubarSeparator,
  MenubarTrigger,
} from "@/components/ui/menubar";

interface MenuBarProps {
  readonly onCreateExperiment?: () => void;
  readonly onCreateJob?: () => void;
}

function extractRouteContext(pathname: string): {
  expId: string | undefined;
  jobId: string | undefined;
} {
  const expMatch = /^\/experiments\/([^/]+)/.exec(pathname);
  const jobMatch = /^\/experiments\/[^/]+\/jobs\/([^/]+)/.exec(pathname);
  return {
    expId: expMatch?.[1],
    jobId: jobMatch?.[1],
  };
}

export function MenuBar({ onCreateExperiment, onCreateJob }: MenuBarProps) {
  const queryClient = useQueryClient();
  const location = useLocation();
  const { expId, jobId } = extractRouteContext(location.pathname);

  const handleReload = () => {
    void queryClient.invalidateQueries();
  };

  return (
    <Menubar className="border-none shadow-none rounded-none h-auto p-0">
      {/* File */}
      <MenubarMenu>
        <MenubarTrigger className="text-sm">File</MenubarTrigger>
        <MenubarContent>
          <MenubarItem disabled>Open Read-only</MenubarItem>
          <MenubarItem disabled>Open Read-write</MenubarItem>
          <MenubarSeparator />
          <MenubarItem onClick={handleReload}>Reload</MenubarItem>
        </MenubarContent>
      </MenubarMenu>

      {/* Search */}
      <MenubarMenu>
        <MenubarTrigger className="text-sm">Search</MenubarTrigger>
        <MenubarContent>
          <MenubarItem disabled>Filter...</MenubarItem>
          <MenubarItem onClick={handleReload}>Reload</MenubarItem>
        </MenubarContent>
      </MenubarMenu>

      {/* Experiment */}
      <MenubarMenu>
        <MenubarTrigger className="text-sm">Experiment</MenubarTrigger>
        <MenubarContent>
          <MenubarItem onClick={onCreateExperiment}>New...</MenubarItem>
          <MenubarSeparator />
          <MenubarItem disabled>Copy...</MenubarItem>
          <MenubarItem disabled={!expId}>Delete</MenubarItem>
          <MenubarItem disabled>Download</MenubarItem>
          <MenubarSeparator />
          <MenubarItem disabled>Change description...</MenubarItem>
          <MenubarItem disabled>Make operational</MenubarItem>
          <MenubarItem disabled>Change ownership</MenubarItem>
          <MenubarItem disabled>Change privacy...</MenubarItem>
          <MenubarItem disabled>Access list...</MenubarItem>
        </MenubarContent>
      </MenubarMenu>

      {/* Job */}
      <MenubarMenu>
        <MenubarTrigger className="text-sm">Job</MenubarTrigger>
        <MenubarContent>
          <MenubarItem disabled={!expId} onClick={onCreateJob}>
            New...
          </MenubarItem>
          <MenubarSeparator />
          <MenubarItem disabled>Copy...</MenubarItem>
          <MenubarItem disabled={!jobId}>Delete...</MenubarItem>
          <MenubarItem disabled>Force Close...</MenubarItem>
          <MenubarSeparator />
          <MenubarItem disabled>Change description...</MenubarItem>
          <MenubarItem disabled>Change identifier...</MenubarItem>
          <MenubarItem disabled>Upgrade version...</MenubarItem>
          <MenubarItem disabled>Difference</MenubarItem>
        </MenubarContent>
      </MenubarMenu>

      {/* Help */}
      <MenubarMenu>
        <MenubarTrigger className="text-sm">Help</MenubarTrigger>
        <MenubarContent>
          <MenubarItem disabled>Introduction</MenubarItem>
          <MenubarItem disabled>General</MenubarItem>
          <MenubarSeparator />
          <MenubarItem disabled>File menu</MenubarItem>
          <MenubarItem disabled>Search menu</MenubarItem>
          <MenubarItem disabled>Experiment menu</MenubarItem>
          <MenubarItem disabled>Job menu</MenubarItem>
        </MenubarContent>
      </MenubarMenu>
    </Menubar>
  );
}
