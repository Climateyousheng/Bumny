import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";

interface HelpDialogProps {
  readonly open: boolean;
  readonly onOpenChange: (open: boolean) => void;
  readonly title: string;
  readonly text: string;
}

export function HelpDialog({ open, onOpenChange, title, text }: HelpDialogProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[80vh] overflow-y-auto sm:max-w-xl">
        <DialogHeader>
          <DialogTitle>Help: {title}</DialogTitle>
          <DialogDescription>Window help text</DialogDescription>
        </DialogHeader>
        <pre className="whitespace-pre-wrap text-sm">{text || "No help available."}</pre>
      </DialogContent>
    </Dialog>
  );
}
