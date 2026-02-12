import { useCallback, useRef } from "react";
import { Copy, Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useState } from "react";

interface BasisViewerProps {
  readonly content: string;
  readonly lineCount: number;
  readonly loading?: boolean;
}

export function BasisViewer({ content, lineCount, loading }: BasisViewerProps) {
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const [copied, setCopied] = useState(false);

  const handleCopy = useCallback(async () => {
    await navigator.clipboard.writeText(content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }, [content]);

  if (loading) {
    return <Skeleton className="h-96 w-full" />;
  }

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          {lineCount.toLocaleString()} lines
        </p>
        <Button
          variant="outline"
          size="sm"
          onClick={() => void handleCopy()}
        >
          {copied ? (
            <>
              <Check className="mr-1 h-3 w-3" />
              Copied
            </>
          ) : (
            <>
              <Copy className="mr-1 h-3 w-3" />
              Copy
            </>
          )}
        </Button>
      </div>
      <textarea
        ref={textareaRef}
        readOnly
        value={content}
        className="h-[60vh] w-full resize-none rounded-md border bg-muted/30 p-4 font-mono text-xs leading-relaxed focus:outline-none"
        aria-label="Basis file content"
      />
    </div>
  );
}
