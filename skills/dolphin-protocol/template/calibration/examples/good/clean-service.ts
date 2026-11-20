// LABEL: good — errors surface with context; names tell the truth;
// no type escapes; TODO carries owner + date.
export function getOrderTotal(order: Order): Money {
  return order.items.reduce((sum, item) => sum.plus(item.price), Money.zero());
}

export function saveOrder(order: Order): SaveResult {
  try {
    db.save(order);
    return { ok: true };
  } catch (err) {
    log.error("saveOrder failed", { err, orderId: order.id });
    return { ok: false, reason: "storage" };
  }
  // TODO(bagas, 2026-12-01): split billing when orders v2 lands
}
