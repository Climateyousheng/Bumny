import { createBrowserRouter } from "react-router-dom";
import { AppShell } from "@/components/layout/app-shell";
import { ExperimentListPage } from "@/components/experiments/experiment-list-page";
import { ExperimentDetailPage } from "@/components/experiment-detail/experiment-detail-page";
import { JobDetailPage } from "@/components/job-detail/job-detail-page";

export const router = createBrowserRouter([
  {
    element: <AppShell />,
    children: [
      { index: true, element: <ExperimentListPage /> },
      { path: "experiments/:expId", element: <ExperimentDetailPage /> },
      { path: "experiments/:expId/jobs/:jobId", element: <JobDetailPage /> },
    ],
  },
]);
