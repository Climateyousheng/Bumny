import { createBrowserRouter } from "react-router-dom";
import { AppShell } from "@/components/layout/app-shell";
import { ExplorerPage } from "@/components/explorer/explorer-page";
import { ExperimentDetailPage } from "@/components/experiment-detail/experiment-detail-page";
import { JobDetailPage } from "@/components/job-detail/job-detail-page";
import { BridgePage } from "@/components/bridge/bridge-page";

export const router = createBrowserRouter([
  {
    element: <AppShell />,
    children: [
      { index: true, element: <ExplorerPage /> },
      { path: "experiments", element: <ExplorerPage /> },
      { path: "experiments/:expId", element: <ExperimentDetailPage /> },
      { path: "experiments/:expId/jobs/:jobId", element: <JobDetailPage /> },
      { path: "experiments/:expId/jobs/:jobId/bridge", element: <BridgePage /> },
    ],
  },
]);
