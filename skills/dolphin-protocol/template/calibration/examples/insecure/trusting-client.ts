// LABEL: insecure — the server trusts a client-supplied owner id;
// no authz check; the row-level policy is "the UI hides it".
export async function listDocuments(req: Request) {
  const { userId } = await req.json();
  return db.query("SELECT * FROM documents WHERE owner_id = $1", [userId]);
}
