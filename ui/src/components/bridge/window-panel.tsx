import { useState } from "react";
import { useWindow, useWindowHelp, useWindowVariables, useVariables } from "@/hooks/use-bridge";
import { WindowHeader } from "./window-header";
import { HelpDialog } from "./help-dialog";
import { ComponentRenderer } from "./component-renderer";
import { DummyPlaceholder } from "./components/dummy-placeholder";
import { LoadingSkeleton } from "@/components/shared/loading-skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";

interface WindowPanelProps {
  readonly winId: string;
  readonly expId: string;
  readonly jobId: string;
  readonly onNavigate: (winId: string) => void;
}

export function WindowPanel({ winId, expId, jobId, onNavigate }: WindowPanelProps) {
  const [helpOpen, setHelpOpen] = useState(false);

  const { data: window, isLoading: winLoading, error: winError } = useWindow(winId);
  const { data: help } = useWindowHelp(winId);
  const { data: windowVars } = useWindowVariables(expId, jobId, winId);
  const { data: allVars } = useVariables(expId, jobId);

  if (winLoading) return <LoadingSkeleton />;
  if (winError) return <ErrorAlert message={winError.message} />;
  if (!window) return <ErrorAlert message="Window not found" />;

  const variables = windowVars ?? {};
  const allVariables = allVars ?? {};

  return (
    <div className="space-y-4">
      <WindowHeader
        title={window.title}
        onHelpClick={() => setHelpOpen(true)}
      />

      {window.win_type === "dummy" ? (
        <DummyPlaceholder title={window.title} />
      ) : (
        <div className="space-y-2">
          {window.components.map((comp, i) => (
            <ComponentRenderer
              key={i}
              component={comp}
              variables={variables}
              allVariables={allVariables}
              onNavigate={onNavigate}
            />
          ))}
        </div>
      )}

      <HelpDialog
        open={helpOpen}
        onOpenChange={setHelpOpen}
        title={window.title}
        text={help?.text ?? ""}
      />
    </div>
  );
}
