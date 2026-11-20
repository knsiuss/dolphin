export function saveOrder(order: Order): SaveResult {
  try {
    db.save(order);
    return { ok: true };
  } catch (err) {
    log.error("saveOrder failed", { err, orderId: order.id });
    return { ok: false, reason: "storage" };
  }
  // TODO(bagas, 2026-12-01): split billing once orders v2 lands
}
