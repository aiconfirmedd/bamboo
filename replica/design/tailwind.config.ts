import type { Config } from "tailwindcss";

// Bamboo Tailwind mapping. Token values live in replica/design/tokens.json and
// tokens.css; this file only maps roles to utility names.
const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./lib/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        bg: "var(--color-bg)",
        surface: "var(--color-surface)",
        "surface-raised": "var(--color-surface-raised)",
        border: "var(--color-border)",
        "border-input": "var(--color-border-input)",
        text: "var(--color-text)",
        "text-muted": "var(--color-text-muted)",
        accent: "var(--color-accent)",
        "accent-hover": "var(--color-accent-hover)",
        "accent-text": "var(--color-accent-text)",
        "accent-tint": "var(--color-accent-tint)",
        "on-accent": "var(--color-on-accent)",
        danger: "var(--color-danger)",
        "danger-tint": "var(--color-danger-tint)",
        success: "var(--color-success)",
        "success-tint": "var(--color-success-tint)",
        warning: "var(--color-warning)",
        "warning-tint": "var(--color-warning-tint)",
        "focus-ring": "var(--color-focus-ring)",
      },
      fontFamily: {
        sans: ["var(--font-sans)"],
        mono: ["var(--font-mono)"],
      },
      fontSize: {
        xs: ["var(--text-xs)", { lineHeight: "var(--text-xs-line)" }],
        sm: ["var(--text-sm)", { lineHeight: "var(--text-sm-line)" }],
        base: ["var(--text-base)", { lineHeight: "var(--text-base-line)" }],
        lg: ["var(--text-lg)", { lineHeight: "var(--text-lg-line)" }],
        xl: ["var(--text-xl)", { lineHeight: "var(--text-xl-line)" }],
        display: ["var(--text-display)", { lineHeight: "var(--text-display-line)" }],
      },
      borderRadius: {
        sm: "var(--radius-sm)",
        md: "var(--radius-md)",
        lg: "var(--radius-lg)",
        pill: "var(--radius-pill)",
      },
      boxShadow: {
        card: "var(--shadow-card)",
        pop: "var(--shadow-pop)",
      },
      transitionDuration: {
        fast: "var(--motion-fast)",
        base: "var(--motion-base)",
      },
      transitionTimingFunction: {
        out: "var(--motion-ease)",
      },
      maxWidth: { content: "var(--layout-max)" },
      height: { header: "var(--layout-header)", row: "var(--layout-row)" },
      screens: { sm: "640px", md: "768px", lg: "1024px", xl: "1280px" },
    },
  },
  plugins: [],
};

export default config;
