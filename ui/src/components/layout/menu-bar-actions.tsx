import { useState, useCallback } from "react";
import { useLocation } from "react-router-dom";
import { useExperiment } from "@/hooks/use-experiments";
import { useJob } from "@/hooks/use-jobs";
import { CopyExperimentDialog } from "@/components/experiments/copy-experiment-dialog";
import { DeleteExperimentDialog } from "@/components/experiments/delete-experiment-dialog";
import { ChangeExpDescriptionDialog } from "@/components/experiments/change-description-dialog";
import { ChangePrivacyDialog } from "@/components/experiments/change-privacy-dialog";
import { AccessListDialog } from "@/components/experiments/access-list-dialog";
import { CopyJobDialog } from "@/components/jobs/copy-job-dialog";
import { DeleteJobDialog } from "@/components/jobs/delete-job-dialog";
import { ChangeJobDescriptionDialog } from "@/components/jobs/change-description-dialog";
import { ForceCloseDialog } from "@/components/jobs/force-close-dialog";
import { MenuBar } from "./menu-bar";

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

type DialogType =
  | "copyExp"
  | "deleteExp"
  | "changeExpDesc"
  | "changePrivacy"
  | "accessList"
  | "copyJob"
  | "deleteJob"
  | "changeJobDesc"
  | "forceClose"
  | null;

interface MenuBarActionsProps {
  readonly onCreateExperiment?: () => void;
  readonly onCreateJob?: () => void;
}

export function MenuBarActions({ onCreateExperiment, onCreateJob }: MenuBarActionsProps) {
  const location = useLocation();
  const { expId, jobId } = extractRouteContext(location.pathname);

  const [openDialog, setOpenDialog] = useState<DialogType>(null);

  const { data: experiment } = useExperiment(expId ?? "", {
    enabled: !!expId,
  });
  const { data: job } = useJob(expId ?? "", jobId ?? "", {
    enabled: !!expId && !!jobId,
  });

  const open = useCallback((d: DialogType) => () => setOpenDialog(d), []);
  const close = useCallback(() => setOpenDialog(null), []);

  return (
    <>
      <MenuBar
        onCreateExperiment={onCreateExperiment}
        onCreateJob={onCreateJob}
        onCopyExperiment={open("copyExp")}
        onDeleteExperiment={open("deleteExp")}
        onChangeExpDescription={open("changeExpDesc")}
        onChangeExpPrivacy={open("changePrivacy")}
        onExpAccessList={open("accessList")}
        onCopyJob={open("copyJob")}
        onDeleteJob={open("deleteJob")}
        onChangeJobDescription={open("changeJobDesc")}
        onForceCloseJob={open("forceClose")}
      />

      {experiment && (
        <>
          <CopyExperimentDialog
            experiment={experiment}
            open={openDialog === "copyExp"}
            onOpenChange={(v) => !v && close()}
          />
          <DeleteExperimentDialog
            experiment={experiment}
            open={openDialog === "deleteExp"}
            onOpenChange={(v) => !v && close()}
          />
          <ChangeExpDescriptionDialog
            expId={experiment.id}
            currentDescription={experiment.description}
            open={openDialog === "changeExpDesc"}
            onOpenChange={(v) => !v && close()}
          />
          <ChangePrivacyDialog
            expId={experiment.id}
            currentPrivacy={experiment.privacy}
            open={openDialog === "changePrivacy"}
            onOpenChange={(v) => !v && close()}
          />
          <AccessListDialog
            expId={experiment.id}
            currentAccessList={experiment.access_list}
            open={openDialog === "accessList"}
            onOpenChange={(v) => !v && close()}
          />
        </>
      )}

      {experiment && job && expId && (
        <>
          <CopyJobDialog
            expId={expId}
            job={job}
            open={openDialog === "copyJob"}
            onOpenChange={(v) => !v && close()}
          />
          <DeleteJobDialog
            expId={expId}
            job={job}
            open={openDialog === "deleteJob"}
            onOpenChange={(v) => !v && close()}
          />
          <ChangeJobDescriptionDialog
            expId={expId}
            jobId={job.job_id}
            currentDescription={job.description}
            open={openDialog === "changeJobDesc"}
            onOpenChange={(v) => !v && close()}
          />
          <ForceCloseDialog
            expId={expId}
            jobId={job.job_id}
            open={openDialog === "forceClose"}
            onOpenChange={(v) => !v && close()}
          />
        </>
      )}
    </>
  );
}
