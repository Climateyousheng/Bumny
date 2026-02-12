import { useState } from "react";
import { Loader2, CheckCircle2, XCircle, FileCode } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useProcessJob, useSubmitJob } from "@/hooks/use-process";
import type { SubmitResponse } from "@/types/process";

type Step = "process" | "review" | "submit" | "result";

interface ProcessDialogProps {
  readonly expId: string;
  readonly jobId: string;
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
}

export function ProcessDialog({
  expId,
  jobId,
  open,
  onOpenChange,
}: ProcessDialogProps) {
  const [step, setStep] = useState<Step>("process");
  const [processedFiles, setProcessedFiles] = useState<Record<string, string>>({});
  const [warnings, setWarnings] = useState<readonly string[]>([]);
  const [selectedFile, setSelectedFile] = useState<string | null>(null);
  const [targetHost, setTargetHost] = useState("");
  const [targetUser, setTargetUser] = useState("");
  const [submitResult, setSubmitResult] = useState<SubmitResponse | null>(null);

  const processMutation = useProcessJob();
  const submitMutation = useSubmitJob();

  const handleProcess = async () => {
    const result = await processMutation.mutateAsync({ expId, jobId });
    setProcessedFiles(result.files);
    setWarnings(result.warnings);
    setStep("review");
  };

  const handleSubmit = async () => {
    const result = await submitMutation.mutateAsync({
      expId,
      jobId,
      request: {
        target_host: targetHost,
        target_user: targetUser,
        processed_files: processedFiles,
      },
    });
    setSubmitResult(result);
    setStep("result");
  };

  const handleClose = () => {
    onOpenChange(false);
    // Reset state after close animation
    setTimeout(() => {
      setStep("process");
      setProcessedFiles({});
      setWarnings([]);
      setSelectedFile(null);
      setTargetHost("");
      setTargetUser("");
      setSubmitResult(null);
      processMutation.reset();
      submitMutation.reset();
    }, 200);
  };

  const fileNames = Object.keys(processedFiles);

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="max-w-4xl max-h-[80vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle>
            Process & Submit: {expId}/{jobId}
          </DialogTitle>
          <DialogDescription>
            {step === "process" && "Generate job scripts from templates."}
            {step === "review" && `${fileNames.length} files generated. Review before submitting.`}
            {step === "submit" && "Enter remote target details to submit."}
            {step === "result" && "Submission complete."}
          </DialogDescription>
        </DialogHeader>

        {step === "process" && (
          <div className="flex flex-col items-center gap-4 py-8">
            <p className="text-sm text-muted-foreground">
              This will expand processing templates using the basis file variables.
            </p>
            <Button
              onClick={() => void handleProcess()}
              disabled={processMutation.isPending}
            >
              {processMutation.isPending && (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              )}
              Process Job
            </Button>
            {processMutation.isError && (
              <p className="text-sm text-destructive">
                {processMutation.error.message}
              </p>
            )}
          </div>
        )}

        {step === "review" && (
          <div className="flex flex-1 gap-4 overflow-hidden">
            <div className="w-48 shrink-0 overflow-y-auto border-r pr-2">
              <p className="mb-2 text-xs font-medium text-muted-foreground">
                Generated Files
              </p>
              {fileNames.map((name) => (
                <button
                  key={name}
                  type="button"
                  className={`flex w-full items-center gap-1 rounded px-2 py-1 text-left text-xs hover:bg-accent ${
                    selectedFile === name ? "bg-accent" : ""
                  }`}
                  onClick={() => setSelectedFile(name)}
                >
                  <FileCode className="h-3 w-3 shrink-0" />
                  {name}
                </button>
              ))}
            </div>
            <div className="flex-1 overflow-y-auto">
              {selectedFile ? (
                <pre className="whitespace-pre-wrap break-all rounded bg-muted p-3 text-xs font-mono">
                  {processedFiles[selectedFile]}
                </pre>
              ) : (
                <p className="py-8 text-center text-sm text-muted-foreground">
                  Select a file to preview its contents.
                </p>
              )}
            </div>
          </div>
        )}

        {step === "review" && (
          <div className="flex items-center justify-between border-t pt-4">
            {warnings.length > 0 && (
              <p className="text-xs text-amber-600">
                {warnings.length} warning(s) during processing
              </p>
            )}
            <div className="ml-auto">
              <Button onClick={() => setStep("submit")}>
                Continue to Submit
              </Button>
            </div>
          </div>
        )}

        {step === "submit" && (
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="target-host">Target Host</Label>
              <Input
                id="target-host"
                placeholder="e.g. archer2"
                value={targetHost}
                onChange={(e) => setTargetHost(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="target-user">Username</Label>
              <Input
                id="target-user"
                placeholder="e.g. nd20983"
                value={targetUser}
                onChange={(e) => setTargetUser(e.target.value)}
              />
            </div>
            <div className="flex gap-2">
              <Button
                variant="outline"
                onClick={() => setStep("review")}
              >
                Back
              </Button>
              <Button
                onClick={() => void handleSubmit()}
                disabled={submitMutation.isPending || !targetHost || !targetUser}
              >
                {submitMutation.isPending && (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                )}
                Submit to HPC
              </Button>
            </div>
            {submitMutation.isError && (
              <p className="text-sm text-destructive">
                {submitMutation.error.message}
              </p>
            )}
          </div>
        )}

        {step === "result" && submitResult && (
          <div className="space-y-4 py-4">
            <div className="flex items-center gap-2">
              {submitResult.success ? (
                <>
                  <CheckCircle2 className="h-5 w-5 text-green-600" />
                  <span className="font-medium text-green-600">
                    Submitted successfully
                  </span>
                </>
              ) : (
                <>
                  <XCircle className="h-5 w-5 text-destructive" />
                  <span className="font-medium text-destructive">
                    Submission failed (exit {submitResult.exit_status})
                  </span>
                </>
              )}
            </div>
            <div className="space-y-1 text-sm">
              <p>
                <span className="font-medium">Submit ID:</span>{" "}
                <code className="font-mono">{submitResult.submit_id}</code>
              </p>
              <p>
                <span className="font-medium">Remote Dir:</span>{" "}
                <code className="font-mono">{submitResult.remote_dir}</code>
              </p>
            </div>
            {submitResult.stdout && (
              <div>
                <p className="mb-1 text-xs font-medium">stdout</p>
                <pre className="whitespace-pre-wrap rounded bg-muted p-2 text-xs font-mono">
                  {submitResult.stdout}
                </pre>
              </div>
            )}
            {submitResult.stderr && (
              <div>
                <p className="mb-1 text-xs font-medium">stderr</p>
                <pre className="whitespace-pre-wrap rounded bg-muted p-2 text-xs font-mono text-destructive">
                  {submitResult.stderr}
                </pre>
              </div>
            )}
            <Button variant="outline" onClick={handleClose}>
              Close
            </Button>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
