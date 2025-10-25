"use client";

import { useState, useEffect } from "react";

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
    <div className="relative flex h-auto min-h-screen w-full flex-col overflow-x-hidden bg-[#f6f7f8] dark:bg-[#101922] text-[#0d141b] dark:text-slate-50">
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
                className="flex items-center justify-center gap-2 min-w-[84px] max-w-[480px] cursor-pointer rounded-lg h-10 px-4 bg-slate-200 dark:bg-slate-700 text-sm font-bold hover:bg-slate-300 dark:hover:bg-slate-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span className="material-symbols-outlined text-base">
                  refresh
                </span>
                <span className="truncate">Refresh</span>
              </button>
            </div>

            {/* Information Banner */}
            <div className="p-4">
              <div className="flex flex-1 flex-col items-start justify-between gap-4 rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-100 dark:bg-slate-800 p-5">
                <div className="flex flex-col gap-1">
                  <p className="text-base font-bold">Information</p>
                  <p className="text-slate-600 dark:text-slate-400 text-sm">
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
                    className="flex flex-col gap-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 p-4 shadow-sm animate-pulse"
                  >
                    <div className="h-4 bg-slate-200 dark:bg-slate-700 rounded w-1/3"></div>
                    <div className="h-12 bg-slate-200 dark:bg-slate-700 rounded"></div>
                    <div className="h-5 bg-slate-200 dark:bg-slate-700 rounded w-1/4"></div>
                  </div>
                ))}
              </div>
            )}

            {/* Error State */}
            {error && !loading && (
              <div className="p-4">
                <div className="flex flex-col items-center justify-center gap-4 rounded-lg border border-red-200 dark:border-red-900/50 bg-red-50 dark:bg-red-900/20 p-8 text-center">
                  <span className="material-symbols-outlined text-3xl text-red-600 dark:text-red-400">
                    error_outline
                  </span>
                  <p className="text-red-800 dark:text-red-200 font-semibold">
                    Failed to load system variables.
                  </p>
                  <button
                    onClick={handleRefresh}
                    className="flex items-center justify-center gap-2 min-w-[84px] cursor-pointer rounded-lg h-10 px-4 bg-[#137fec] text-white text-sm font-bold hover:bg-[#137fec]/90 transition-colors"
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
                    className="flex flex-col gap-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 p-4 shadow-sm"
                  >
                    {/* Label and Copy Button */}
                    <div className="flex items-center justify-between">
                      <label className="text-sm font-medium text-slate-500 dark:text-slate-400">
                        {variable.label}
                      </label>
                      <button
                        onClick={() => copyToClipboard(variable.value)}
                        disabled={!variable.configured}
                        className={`flex items-center justify-center rounded-md h-8 w-8 transition-colors ${
                          variable.configured
                            ? "hover:bg-slate-100 dark:hover:bg-slate-800 cursor-pointer"
                            : "text-slate-400 dark:text-slate-500 cursor-not-allowed"
                        }`}
                      >
                        <span className="material-symbols-outlined text-base">
                          content_copy
                        </span>
                      </button>
                    </div>

                    {/* Input Field */}
                    {variable.type === "password" && variable.configured ? (
                      <div className="relative">
                        <input
                          aria-readonly="true"
                          className="w-full bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg p-3 text-base text-slate-900 dark:text-slate-100"
                          readOnly
                          type={
                            visiblePasswords.has(index) ? "text" : "password"
                          }
                          value={variable.value || ""}
                        />
                        <button
                          onClick={() => togglePasswordVisibility(index)}
                          className="absolute inset-y-0 right-0 flex items-center pr-3 hover:text-slate-700 dark:hover:text-slate-300 transition-colors"
                          type="button"
                        >
                          <span className="material-symbols-outlined text-slate-500 text-base">
                            {visiblePasswords.has(index)
                              ? "visibility"
                              : "visibility_off"}
                          </span>
                        </button>
                      </div>
                    ) : (
                      <input
                        aria-readonly="true"
                        className={`w-full bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg p-3 text-base ${
                          variable.configured
                            ? "text-slate-900 dark:text-slate-100"
                            : "text-slate-500 dark:text-slate-400 placeholder:text-slate-400 dark:placeholder:text-slate-500"
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
                        className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                          variable.configured
                            ? "bg-green-100 dark:bg-green-900/50 text-green-800 dark:text-green-300"
                            : "bg-yellow-100 dark:bg-yellow-900/50 text-yellow-800 dark:text-yellow-400"
                        }`}
                      >
                        {variable.configured ? "Configured" : "Not Set"}
                      </span>
                      <p className="text-xs text-slate-500 dark:text-slate-400">
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
        <div className="fixed bottom-5 right-5 bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 text-sm font-semibold py-2 px-4 rounded-lg shadow-lg animate-in fade-in slide-in-from-bottom-2 duration-200">
          Copied to clipboard
        </div>
      )}
    </div>
  );
}
