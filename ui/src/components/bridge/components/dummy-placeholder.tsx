export function DummyPlaceholder() {
  return (
    <div className="flex items-center justify-center rounded-md border border-dashed p-8 text-muted-foreground">
      <p className="text-sm">
        This window invokes a Tcl routine and has no editable fields.
      </p>
    </div>
  );
}
