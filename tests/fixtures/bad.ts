// ============================================
// order service
// ============================================
export function saveOrder(order: unknown) {
  try {
    db.save(order as any);
  } catch (e) {}
  // TODO fix this later
  // if (order.total > 100) {
  return true;
}
