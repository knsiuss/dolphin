// LABEL: slop — names that lie (get* mutates), generic identifiers,
// a re-implemented helper that already exists in src/lib/format.ts.
// ============================================
// utils
// ============================================
export function getUserData(data: any) {
  data2.lastFetched = Date.now(); // mutates its argument
  saveToCache(data); // and writes — while named "get"
  return data;
}

export function formatCurrency2(value: any) {
  // duplicate of formatCurrency in src/lib/format.ts
  return "Rp" + value;
}
