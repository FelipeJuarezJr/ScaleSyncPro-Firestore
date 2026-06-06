"use client";

import { useEffect } from "react";

export default function DevAdminInitializer() {
  useEffect(() => {
    // Only apply in development mode
    if (process.env.NODE_ENV === "development") {
      document.cookie = "__session=dev-admin-bypass; path=/; max-age=3600; SameSite=Lax;";
      console.log("Dev admin cookie initialized by DevAdminInitializer");
    }
  }, []);

  return null;
}
