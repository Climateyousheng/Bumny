interface DummyPlaceholderProps {
  readonly title: string;
}

export function DummyPlaceholder({ title }: DummyPlaceholderProps) {
  return (
    <div className="flex items-center justify-center rounded-md border border-dashed p-8 text-muted-foreground">
      <p className="text-sm">
        <span className="font-medium">{title}</span> is a placeholder window with no editable fields.
      </p>
    </div>
  );
}
