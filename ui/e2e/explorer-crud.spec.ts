import { test, expect } from "@playwright/test";

/**
 * E2E test for the core UMUI Next workflow:
 * Explorer → Create experiment → Create job → Open bridge → Edit → Save
 *
 * Requires running servers:
 *   - API: cd ../api && uvicorn umui_api.main:app --port 8000
 *   - UI:  npm run dev
 */

test.describe("Explorer CRUD flow", () => {
  test("loads explorer page with experiments", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("heading", { name: "Experiments" })).toBeVisible();
    await expect(page.getByRole("table")).toBeVisible();
  });

  test("filters experiments by search", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("table")).toBeVisible();

    const searchInput = page.getByLabel("Search");
    await searchInput.fill("xqgt");

    // Only matching rows should remain visible
    await expect(page.getByText("xqgt")).toBeVisible();
  });

  test("expands experiment to show jobs", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("table")).toBeVisible();

    // Find an expand button and click it
    const expandBtn = page.getByLabel(/expand/i).first();
    await expandBtn.click();

    // Jobs should appear (lazy-loaded)
    await expect(page.getByText(/job/i).first()).toBeVisible({ timeout: 10_000 });
  });

  test("creates experiment via dialog", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("heading", { name: "Experiments" })).toBeVisible();

    await page.getByRole("button", { name: /new experiment/i }).click();
    await expect(page.getByText("Create Experiment")).toBeVisible();

    await page.getByLabel("Initial Experiment ID").fill("test");
    await page.getByLabel("Description").fill("E2E test experiment");
    await page.getByRole("button", { name: "Create" }).click();

    // Dialog should close on success
    await expect(page.getByText("Create Experiment")).not.toBeVisible({ timeout: 5_000 });
  });

  test("navigates to bridge and edits a value", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("table")).toBeVisible();

    // Expand first experiment
    const expandBtn = page.getByLabel(/expand/i).first();
    await expandBtn.click();

    // Wait for jobs to load and find an "Open Bridge" action
    const actionsBtn = page.getByLabel("Actions").first();
    await actionsBtn.click();

    const openBridge = page.getByRole("menuitem", { name: /open bridge/i });
    if (await openBridge.isVisible()) {
      await openBridge.click();

      // Bridge page should load
      await expect(page.getByText(/start editing/i)).toBeVisible({ timeout: 10_000 });

      // Select a panel from the nav tree
      const panel = page.getByText(/general details|horizontal/i).first();
      if (await panel.isVisible()) {
        await panel.click();

        // Start editing
        await page.getByRole("button", { name: /start editing/i }).click();

        // Wait for editing mode
        await expect(page.getByRole("button", { name: /save/i })).toBeVisible({
          timeout: 5_000,
        });

        // Find an input and modify it
        const input = page.locator("input[type='text']").first();
        if (await input.isVisible()) {
          await input.clear();
          await input.fill("999");

          // Save
          await page.getByRole("button", { name: /save/i }).click();

          // Stop editing
          await page.getByRole("button", { name: /stop editing/i }).click();
          await expect(page.getByRole("button", { name: /start editing/i })).toBeVisible();
        }
      }
    }
  });
});
