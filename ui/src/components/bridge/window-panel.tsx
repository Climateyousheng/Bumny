import { useState } from "react";
import { useWindow, useWindowHelp, useWindowVariables } from "@/hooks/use-bridge";
import { WindowHeader } from "./window-header";
import { HelpDialog } from "./help-dialog";
import { ComponentRenderer } from "./component-renderer";
import { DummyPlaceholder } from "./components/dummy-placeholder";
import { LoadingSkeleton } from "@/components/shared/loading-skeleton";
import { ErrorAlert } from "@/components/shared/error-alert";
import type { VariableValues } from "@/types/bridge";

interface WindowPanelProps {
  readonly winId: string;
  readonly expId: string;
  readonly jobId: string;
  readonly onNavigate: (winId: string) => void;
  readonly isEditing?: boolean;
  readonly onChange?: (variable: string, value: string) => void;
  readonly onChangeArray?: (variable: string, index: number, value: string) => void;
  readonly mergeVariables?: (serverVars: VariableValues) => VariableValues;
}

export function WindowPanel({
  winId,
  expId,
  jobId,
  onNavigate,
  isEditing,
  onChange,
  onChangeArray,
  mergeVariables,
}: WindowPanelProps) {
  const [helpOpen, setHelpOpen] = useState(false);

  const { data: window, isLoading: winLoading, error: winError } = useWindow(winId, expId, jobId);
  const { data: help } = useWindowHelp(winId);
  const { data: windowVars } = useWindowVariables(expId, jobId, winId);

  if (winLoading) return <LoadingSkeleton />;
  if (winError) return <ErrorAlert message={winError.message} />;
  if (!window) return <ErrorAlert message="Window not found" />;

  const serverVars = windowVars ?? {};
  const variables = mergeVariables ? mergeVariables(serverVars) : serverVars;

  return (
    <div className="space-y-4">
      <WindowHeader
        title={window.title}
        onHelpClick={() => setHelpOpen(true)}
      />

      {window.win_type === "dummy" ? (
        <DummyPlaceholder />
      ) : (
        <div className="space-y-2">
          {window.components.map((comp, i) => (
            <ComponentRenderer
              key={i}
              component={comp}
              variables={variables}
              onNavigate={onNavigate}
              isEditing={isEditing}
              onChange={onChange}
              onChangeArray={onChangeArray}
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
