"use client";

import { useState, useEffect } from "react";
import { Copy, Eye, EyeOff, RefreshCw, AlertCircle } from "lucide-react";

interface SystemVariable {
  label: string;
  value: string | null;
  configured: boolean;
  type: "text" | "password";
}

export default function SystemVariablesPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [showToast, setShowToast] = useState(false);
  const [visiblePasswords, setVisiblePasswords] = useState<Set<number>>(
    new Set()
  );
  const [variables, setVariables] = useState<SystemVariable[]>([
    {
      label: "Monitoring Video Page URL",
      value: "https://example.com/monitoring",
      configured: true,
      type: "text",
    },
    {
      label: "Telegram Channel ID",
      value: null,
      configured: false,
      type: "text",
    },
    {
      label: "Telegram Bot Token",
      value: "1234567890",
      configured: true,
      type: "password",
    },
  ]);

  const copyToClipboard = (text: string | null) => {
    if (!text) return;

    navigator.clipboard.writeText(text).then(() => {
      setShowToast(true);
      setTimeout(() => setShowToast(false), 2000);
    });
  };

  const togglePasswordVisibility = (index: number) => {
    setVisiblePasswords((prev) => {
      const newSet = new Set(prev);
      if (newSet.has(index)) {
        newSet.delete(index);
      } else {
        newSet.add(index);
      }
      return newSet;
    });
  };

  const handleRefresh = async () => {
    setLoading(true);
    setError(false);

    try {
      // TODO: Replace with actual API call
      const response = await fetch("/api/v1/admin/system-variables");

      if (!response.ok) {
        throw new Error("Failed to fetch system variables");
      }

      const data = await response.json();
      setVariables(data.variables);
    } catch (err) {
      console.error("Error fetching system variables:", err);
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Initial load - simulate API call
    const timer = setTimeout(() => {
      setLoading(false);
    }, 500);

    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="relative flex h-auto min-h-screen w-full flex-col overflow-x-hidden bg-[var(--color-surface-secondary)] text-[var(--color-foreground)]">
      <div className="layout-container flex h-full grow flex-col">
        <div className="px-4 md:px-10 lg:px-20 xl:px-40 flex flex-1 justify-center py-5">
          <div className="layout-content-container flex flex-col w-full max-w-3xl flex-1">
            {/* Header */}
            <div className="flex flex-wrap justify-between items-center gap-4 p-4">
              <h1 className="text-4xl font-black tracking-tight">
                System Variables
              </h1>
              <button
                onClick={handleRefresh}
                disabled={loading}
                className="flex items-center justify-center gap-2 min-w-[84px] max-w-[480px] cursor-pointer rounded-[var(--radius-lg)] h-10 px-4 bg-[var(--color-muted)] dark:bg-[var(--color-surface)] text-sm font-[var(--font-weight-bold)] hover:bg-[var(--color-border)] dark:hover:bg-[var(--color-border-strong)] transition-[var(--transition-base)] disabled:opacity-50 disabled:cursor-not-allowed shadow-[var(--shadow-sm)]"
              >
                <RefreshCw className="w-4 h-4" />
                <span className="truncate">Refresh</span>
              </button>
            </div>

            {/* Information Banner */}
            <div className="p-4">
              <div className="flex flex-1 flex-col items-start justify-between gap-4 rounded-[var(--radius-lg)] border border-[var(--color-border)] bg-[var(--color-info-light)] p-5">
                <div className="flex flex-col gap-1">
                  <p className="text-base font-[var(--font-weight-bold)]">Information</p>
                  <p className="text-[var(--color-info-light-foreground)] text-sm">
                    These values are sourced from the server&apos;s environment
                    file. To modify them, you must edit the server&apos;s .env
                    file and restart the application.
                  </p>
                </div>
              </div>
            </div>

            {/* Loading State */}
            {loading && (
              <div className="flex flex-col gap-6 p-4">
                {[1, 2, 3].map((i) => (
                  <div
                    key={i}
                    className="flex flex-col gap-4 rounded-[var(--radius-xl)] border border-[var(--color-border)] bg-[var(--color-surface)] p-4 shadow-[var(--shadow-sm)] animate-pulse"
                  >
                    <div className="h-4 bg-[var(--color-muted)] rounded w-1/3"></div>
                    <div className="h-12 bg-[var(--color-muted)] rounded"></div>
                    <div className="h-5 bg-[var(--color-muted)] rounded w-1/4"></div>
                  </div>
                ))}
              </div>
            )}

            {/* Error State */}
            {error && !loading && (
              <div className="p-4">
                <div className="flex flex-col items-center justify-center gap-4 rounded-[var(--radius-lg)] border border-[var(--color-danger)] bg-[var(--color-danger-light)] p-8 text-center">
                  <AlertCircle className="w-8 h-8 text-[var(--color-danger)]" />
                  <p className="text-[var(--color-danger-light-foreground)] font-[var(--font-weight-semibold)]">
                    Failed to load system variables.
                  </p>
                  <button
                    onClick={handleRefresh}
                    className="flex items-center justify-center gap-2 min-w-[84px] cursor-pointer rounded-[var(--radius-lg)] h-10 px-4 bg-[var(--color-primary)] text-[var(--color-primary-foreground)] text-sm font-[var(--font-weight-bold)] hover:bg-[var(--color-primary-hover)] transition-[var(--transition-base)] shadow-[var(--shadow-sm)]"
                  >
                    <span className="truncate">Retry</span>
                  </button>
                </div>
              </div>
            )}

            {/* Variable Cards */}
            {!loading && !error && (
              <div className="flex flex-col gap-6 p-4">
                {variables.map((variable, index) => (
                  <div
                    key={index}
                    className="flex flex-col gap-4 rounded-[var(--radius-xl)] border border-[var(--color-border)] bg-[var(--color-surface)] p-4 shadow-[var(--shadow-sm)]"
                  >
                    {/* Label and Copy Button */}
                    <div className="flex items-center justify-between">
                      <label className="text-sm font-[var(--font-weight-medium)] text-[var(--color-muted-foreground)]">
                        {variable.label}
                      </label>
                      <button
                        onClick={() => copyToClipboard(variable.value)}
                        disabled={!variable.configured}
                        className={`flex items-center justify-center rounded-[var(--radius-md)] h-8 w-8 transition-[var(--transition-base)] ${
                          variable.configured
                            ? "hover:bg-[var(--color-muted)] cursor-pointer"
                            : "text-[var(--color-muted-foreground)] opacity-40 cursor-not-allowed"
                        }`}
                      >
                        <Copy className="w-4 h-4" />
                      </button>
                    </div>

                    {/* Input Field */}
                    {variable.type === "password" && variable.configured ? (
                      <div className="relative">
                        <input
                          aria-readonly="true"
                          className="w-full bg-[var(--color-muted)] border border-[var(--color-border)] rounded-[var(--radius-lg)] p-3 text-base text-[var(--color-foreground)]"
                          readOnly
                          type={
                            visiblePasswords.has(index) ? "text" : "password"
                          }
                          value={variable.value || ""}
                        />
                        <button
                          onClick={() => togglePasswordVisibility(index)}
                          className="absolute inset-y-0 right-0 flex items-center pr-3 hover:text-[var(--color-foreground)] transition-[var(--transition-base)]"
                          type="button"
                        >
                          {visiblePasswords.has(index) ? (
                            <Eye className="w-4 h-4 text-[var(--color-muted-foreground)]" />
                          ) : (
                            <EyeOff className="w-4 h-4 text-[var(--color-muted-foreground)]" />
                          )}
                        </button>
                      </div>
                    ) : (
                      <input
                        aria-readonly="true"
                        className={`w-full bg-[var(--color-muted)] border border-[var(--color-border)] rounded-[var(--radius-lg)] p-3 text-base ${
                          variable.configured
                            ? "text-[var(--color-foreground)]"
                            : "text-[var(--color-muted-foreground)] placeholder:text-[var(--color-muted-foreground)]"
                        }`}
                        placeholder={
                          !variable.configured ? "Not configured" : ""
                        }
                        readOnly
                        type="text"
                        value={variable.value || ""}
                      />
                    )}

                    {/* Status Badge */}
                    <div className="flex items-center gap-2">
                      <span
                        className={`inline-flex items-center rounded-[var(--radius-full)] px-2.5 py-0.5 text-xs font-[var(--font-weight-medium)] ${
                          variable.configured
                            ? "bg-[var(--color-success-light)] text-[var(--color-success-light-foreground)]"
                            : "bg-[var(--color-warning-light)] text-[var(--color-warning-light-foreground)]"
                        }`}
                      >
                        {variable.configured ? "Configured" : "Not Set"}
                      </span>
                      <p className="text-xs text-[var(--color-muted-foreground)]">
                        {variable.configured
                          ? variable.type === "password"
                            ? "Set (value withheld for security)"
                            : "Currently configured"
                          : "Not set — update server .env file"}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Toast Notification */}
      {showToast && (
        <div className="fixed bottom-5 right-5 bg-[var(--color-foreground)] text-[var(--color-background)] text-sm font-[var(--font-weight-semibold)] py-2 px-4 rounded-[var(--radius-lg)] shadow-[var(--shadow-xl)] animate-in fade-in slide-in-from-bottom-2 duration-200 z-[var(--z-toast)]">
          Copied to clipboard
        </div>
      )}
    </div>
  );
}
