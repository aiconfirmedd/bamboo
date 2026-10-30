# Bamboo component specs

Every component from the recon list, plus the primitives they are built from.
Tokens refer to `tokens.json` roles — never raw hex. States marked (R) were seen
in recon; the rest are required even though the original's public pages never
showed them. Keyboard and screen-reader behaviour is part of each spec.

## Primitives

```
Button
  variants  primary (accent bg), secondary (surface bg, border), ghost (transparent), danger (danger bg)
  sizes     sm 32px, md 40px, lg 48px; padding 12/16/24 horizontal
  states    default, hover (accent-hover), active (translate-y-px), focus-visible (2px focus-ring, offset 2), disabled (50% opacity, no pointer), loading (spinner replaces icon, label kept for SR)
  tokens    bg accent, text on-accent, radius md, font sm/600, motion fast
  a11y      real <button>, aria-busy while loading, aria-disabled not just visual
  used on   all screens

IconButton
  variants  ghost, secondary; sizes 32/40 square
  states    as Button; tooltip on hover/focus
  a11y      aria-label required, 44px hit area on touch
  used on   S06, S08, S13, S15, S23

Input / Textarea
  states    default (border-input), hover (border text-muted), focus (2px focus-ring), error (danger border + message), disabled, readonly
  tokens    bg bg, border border-input, radius sm, font sm, padding 8/12
  a11y      <label for> always, aria-describedby for help/error, aria-invalid on error
  used on   S05, S14, S18, S22, S29

Select / Combobox
  states    as Input; open listbox, active option, no-results
  a11y      native <select> where possible; combobox pattern with aria-expanded, arrow keys, Esc
  used on   S06 filters, S14, S22, S26 alignment

Checkbox / Radio / Toggle
  states    default, hover, focus-visible, checked, disabled, indeterminate (checkbox)
  tokens    accent checked fill, 20px box, radius sm
  a11y      real inputs, fieldset+legend for groups, 44px label hit area
  used on   S09, S19, S22, S25

DatePicker
  states    default, open calendar, selected, range, disabled day, error
  a11y      grid keyboard nav, month/year labels, typed input fallback
  used on   S14, S25, S27

FileUpload
  states    idle, drag-over, uploading (progress), done, error (retry), size/type rejected
  a11y      button + hidden input, announce progress, list uploaded files with remove
  used on   S10, S11, S15 (resume), S19

Badge / StatusPill
  variants  neutral, accent, success, warning, danger, muted
  tokens    tint bg + matching text role, radius pill, font xs/600
  a11y      text inside, never colour-only
  used on   S12, S13, S20, S23

ProgressBar / Stepper
  states    determinate, indeterminate, complete
  a11y      role=progressbar with valuenow, step list as ordered list with current step
  used on   S19, S20

EmptyState
  parts     icon, title, one-line body, primary action, secondary link
  a11y      heading level 3, action is a real button
  used on   every list screen (S06, S10, S11, S12, S13, S23, S28, S31)

Pagination
  states    first/last disabled, current page, page-size select
  a11y      nav landmark, aria-current=page
  used on   S06, S12, S23

Tooltip
  states    hidden, visible on hover/focus, dismiss on Esc
  a11y      aria-describedby, never the only source of a label
  used on   icon buttons, truncated cells

Toast
  variants  success, error, info; auto-dismiss 5s, pause on hover
  a11y      role=status (polite) / role=alert (assertive for errors), close button
  used on   all mutations

Skeleton
  used on   tables, cards, record pages while loading; respects reduced motion
```

## Composites

```
TopNav
  variants  employee, manager, admin (items appear by role; Settings gear admin-only)
  states    default, active item, condensed on scroll
  tokens    bg bg, border-b border, height header, font sm/500, active = accent-text + 2px accent underline
  a11y      nav landmark, aria-current=page, skip link before it, mobile drawer with focus trap
  used on   all screens

WidgetCard
  variants  welcome, celebrations, company-links, whos-out, my-stuff, whats-happening, insights-metric
  states    empty (R), filled (R), loading, error, admin-configured hidden
  tokens    bg surface-raised, border border, radius lg, shadow card, padding 16
  a11y      h2 per widget, admin edit affordance labelled "Configure <widget>"
  used on   S02, S03

DataTable
  states    empty (R), filled (R), loading skeleton, sorted, filtered, selected rows, permission-masked cells
  tokens    row height, border-b border, header font xs/600 text-muted, hover surface
  a11y      <table> with caption, th scope, sort buttons with aria-sort, row action menu
  used on   S06, S12, S23

FilterChipRow
  states    default, applied (accent-tint), removable, overflow "+N more"
  a11y      group label, chips are buttons with aria-pressed
  used on   S06, S12

TabbedRecordPage
  states    default tab, deep-linked tab, overflow "More" menu, permission-hidden tabs
  a11y      tablist/tab/tabpanel, arrow-key nav, aria-selected
  used on   S08, S15

PipelineBoard
  states    empty column (R), filled column (R), drag-over, collapsed column, stage count
  tokens    column bg surface, card bg bg + shadow card, radius md
  a11y      columns as lists with headings; drag has keyboard alternative (move-to menu)
  used on   S13

TaskList / TaskTile
  states    todo, done (strikethrough + check), overdue (warning), assigned-to-me, assigned-to-other
  tokens    tile bg surface-raised, border, radius md; done = success-tint
  a11y      checkbox per task, assignee in text, progress announced
  used on   S19, S20

ESignBlock
  states    unsigned, signing, signed (hash + timestamp), declined, expired
  tokens    border dashed border-input, radius md, signed = success-tint + lock icon
  a11y      sign action is a button, receipt text readable, document link opens new tab
  used on   S17, S19

Modal / Dialog
  states    open, loading, confirm, destructive
  tokens    overlay rgba(16,24,40,.4), panel bg bg, radius lg, shadow pop, max-w 480
  a11y      focus trap, Esc, aria-modal, labelled by title, return focus on close
  used on   S04, S17, deletes

SectionedForm
  states    default, dirty, validation error per field, submit loading, success
  tokens    section heading lg/600, field gap 16, section gap 32
  a11y      fieldset+legend per section, error summary at top with links
  used on   S14, S18, S22

EmailTemplateEditor
  states    default, merge-tag insert, preview, dirty
  a11y      textarea + tag buttons, preview in dialog
  used on   hiring settings, S17

RatingScale (eNPS 0–10, Likert)
  states    unselected, hover, selected, submitted
  tokens    pill buttons 40px, selected = accent bg on-accent
  a11y      radiogroup, arrow keys, scale ends labelled
  used on   S29, S30

FeedPostCard
  states    default, with points, with core-value tag, edited, deleted placeholder
  a11y      article landmark, author + time readable, actions labelled
  used on   S28, S31

OrgChartNode
  states    collapsed, expanded, current employee, vacant
  a11y      tree pattern, expand buttons labelled
  used on   S07

Avatar / PhotoUpload
  states    initials fallback, photo, uploading, error
  a11y      alt = person name, upload button labelled
  used on   S06, S08

Heatmap
  states    empty, populated, cell focus
  a11y      table fallback with values, legend
  used on   S30

GoalCard / MilestoneList
  states    in-progress, done, aligned (parent link), private, overdue
  a11y      progress text, milestone checkboxes, alignment link labelled
  used on   S26
```

## Rules

- Focus ring: 2px `focus-ring`, offset 2, on every interactive element.
- Minimum touch target 44×44 on mobile.
- Colour is never the only signal (pills carry text, errors carry icons + text).
- Reduced motion: transitions collapse to 0.01ms.
- Every list screen ships an empty state with a real next action.
