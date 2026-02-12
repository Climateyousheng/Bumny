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
  readonly onCopyExperiment?: () => void;
  readonly onDeleteExperiment?: () => void;
  readonly onChangeExpDescription?: () => void;
  readonly onChangeExpPrivacy?: () => void;
  readonly onExpAccessList?: () => void;
  readonly onCopyJob?: () => void;
  readonly onDeleteJob?: () => void;
  readonly onChangeJobDescription?: () => void;
  readonly onForceCloseJob?: () => void;
  readonly onDifference?: () => void;
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

export function MenuBar({
  onCreateExperiment,
  onCreateJob,
  onCopyExperiment,
  onDeleteExperiment,
  onChangeExpDescription,
  onChangeExpPrivacy,
  onExpAccessList,
  onCopyJob,
  onDeleteJob,
  onChangeJobDescription,
  onForceCloseJob,
  onDifference,
}: MenuBarProps) {
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
          <MenubarItem disabled={!expId} onClick={onCopyExperiment}>
            Copy...
          </MenubarItem>
          <MenubarItem disabled={!expId} onClick={onDeleteExperiment}>
            Delete
          </MenubarItem>
          <MenubarItem disabled>Download</MenubarItem>
          <MenubarSeparator />
          <MenubarItem disabled={!expId} onClick={onChangeExpDescription}>
            Change description...
          </MenubarItem>
          <MenubarItem disabled>Make operational</MenubarItem>
          <MenubarItem disabled>Change ownership</MenubarItem>
          <MenubarItem disabled={!expId} onClick={onChangeExpPrivacy}>
            Change privacy...
          </MenubarItem>
          <MenubarItem disabled={!expId} onClick={onExpAccessList}>
            Access list...
          </MenubarItem>
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
          <MenubarItem disabled={!jobId} onClick={onCopyJob}>
            Copy...
          </MenubarItem>
          <MenubarItem disabled={!jobId} onClick={onDeleteJob}>
            Delete...
          </MenubarItem>
          <MenubarItem disabled={!jobId} onClick={onForceCloseJob}>
            Force Close...
          </MenubarItem>
          <MenubarSeparator />
          <MenubarItem disabled={!jobId} onClick={onChangeJobDescription}>
            Change description...
          </MenubarItem>
          <MenubarItem disabled>Change identifier...</MenubarItem>
          <MenubarItem disabled>Upgrade version...</MenubarItem>
          <MenubarItem disabled={!expId} onClick={onDifference}>
            Difference
          </MenubarItem>
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
