# Dolphin Pod — Registry & Settings

## Agents

| Tag | Role | Terminal/PID | Status |
|---|---|---|---|
| _(register with dolphin-init.sh --register)_ | | | |

## Settings

- fix_loop_cap: 3
- review_tiers: T1 light (<150 lines, no sensitive surface) ·
  T2 standard · T3 full (auth/billing/RLS/schema or >150 lines)
- stale_claim_wake_cycles: 2
- secretary_poll_seconds: 5
- secretary_repoke_seconds: 900

## Motion tokens (defaults — amend per project in the scope doc)

- duration-micro: 150ms · duration-show: 250ms · duration-screen: 350ms
- easing-enter: cubic-bezier(0.23, 1, 0.32, 1)
- easing-exit: cubic-bezier(0.4, 0, 1, 1)
- easing-move: cubic-bezier(0.4, 0, 0.2, 1)
- stagger-group: 50–100ms, within a real group only
- UI motion ceiling: 300ms · animate transform & opacity only ·
  no animation for keyboard-initiated or 100+/day actions
