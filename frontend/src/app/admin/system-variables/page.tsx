"use client";

import { useState, useEffect } from "react";
import { Copy, Eye, EyeOff, RefreshCw, AlertCircle, Info } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import {
  fetchSystemVariables,
  type SystemVariable,
} from "@/lib/api/system-variables";

export default function SystemVariablesPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [visiblePasswords, setVisiblePasswords] = useState<Set<number>>(
    new Set()
  );
  const [variables, setVariables] = useState<SystemVariable[]>([]);

  const copyToClipboard = (text: string | null) => {
    if (!text) return;

    navigator.clipboard.writeText(text).then(() => {
      toast.success("Copied to clipboard");
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
      const data = await fetchSystemVariables();
      setVariables(data);
      toast.success("System variables refreshed");
    } catch (err) {
      console.error("Error fetching system variables:", err);
      setError(true);
      toast.error("Failed to load system variables");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    handleRefresh();
  }, []);

  return (
    <div className="bg-gray-50 dark:bg-gray-900">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        {/* Header */}
        <div className="flex flex-wrap justify-between items-center gap-4 mb-8">
          <div>
            <h1 className="text-4xl font-bold tracking-tight">
              System Variables
            </h1>
            <p className="text-gray-600 mt-2">
              Manage your system configuration and environment variables
            </p>
          </div>
          <Button
            onClick={handleRefresh}
            disabled={loading}
            variant="outline"
            size="default"
          >
            <RefreshCw className={cn("w-4 h-4", loading && "animate-spin")} />
            Refresh
          </Button>
        </div>

        {/* Information Alert */}
        <Alert variant="info" className="mb-6">
          <Info className="h-4 w-4" />
          <AlertTitle>Information</AlertTitle>
          <AlertDescription>
            These values are sourced from the server&apos;s environment file. To
            modify them, you must edit the server&apos;s .env file and restart
            the application.
          </AlertDescription>
        </Alert>

        {/* Loading State */}
        {loading && (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <Card key={i}>
                <CardHeader>
                  <Skeleton className="h-4 w-1/3" />
                </CardHeader>
                <CardContent className="space-y-4">
                  <Skeleton className="h-10 w-full" />
                  <Skeleton className="h-5 w-1/4" />
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {/* Error State */}
        {error && !loading && (
          <Card className="border-red-600">
            <CardContent className="flex flex-col items-center justify-center gap-4 py-8">
              <AlertCircle className="w-12 h-12 text-red-600" />
              <CardTitle className="text-red-600">
                Failed to load system variables
              </CardTitle>
              <CardDescription>
                An error occurred while fetching the system variables. Please
                try again.
              </CardDescription>
              <Button onClick={handleRefresh} variant="default">
                Retry
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Variable Cards */}
        {!loading && !error && (
          <div className="space-y-4">
            {variables.map((variable, index) => (
              <Card key={index}>
                <CardHeader className="pb-4">
                  <div className="flex items-center justify-between">
                    <CardTitle className="text-base font-medium">
                      {variable.label}
                    </CardTitle>
                    <Button
                      onClick={() => copyToClipboard(variable.value)}
                      disabled={!variable.configured}
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                    >
                      <Copy className="w-4 h-4" />
                      <span className="sr-only">Copy to clipboard</span>
                    </Button>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  {/* Input Field */}
                  <div className="relative">
                    <Input
                      readOnly
                      type={
                        variable.type === "password" &&
                        !visiblePasswords.has(index)
                          ? "password"
                          : "text"
                      }
                      value={variable.value || ""}
                      placeholder={!variable.configured ? "Not configured" : ""}
                      className={cn(
                        "pr-10",
                        !variable.configured &&
                          "text-gray-500 placeholder:text-gray-500"
                      )}
                    />
                    {variable.type === "password" && variable.configured && (
                      <Button
                        onClick={() => togglePasswordVisibility(index)}
                        variant="ghost"
                        size="icon"
                        className="absolute inset-y-0 right-0 h-full w-10 hover:bg-transparent"
                        type="button"
                      >
                        {visiblePasswords.has(index) ? (
                          <EyeOff className="w-4 h-4 text-gray-500" />
                        ) : (
                          <Eye className="w-4 h-4 text-gray-500" />
                        )}
                        <span className="sr-only">
                          {visiblePasswords.has(index)
                            ? "Hide password"
                            : "Show password"}
                        </span>
                      </Button>
                    )}
                  </div>

                  {/* Status Badge and Description */}
                  <div className="flex items-center gap-2">
                    <Badge
                      variant={variable.configured ? "success" : "warning"}
                      className="capitalize"
                    >
                      {variable.configured ? "Configured" : "Not Set"}
                    </Badge>
                    <span className="text-sm text-gray-600">
                      {variable.configured
                        ? variable.type === "password"
                          ? "Set (value withheld for security)"
                          : "Currently configured"
                        : "Not set — update server .env file"}
                    </span>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
