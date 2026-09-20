const input = document.querySelector("#file");
const status = document.querySelector("#status");
const list = document.querySelector("#files");
const credentials = () => {
  const user = prompt("FTP username"); const password = prompt("FTP password");
  return user && password ? "Basic " + btoa(user + ":" + password) : null;
};
async function loadFiles(auth) {
  const response = await fetch("files", { headers: { Authorization: auth } });
  const result = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(result.error || response.status);
  list.replaceChildren(...result.files.map(name => new Option(name, name)));
  status.textContent = `${result.files.length} files loaded`;
}
document.querySelector("#upload").onclick = async () => {
  if (!input.files[0]) return (status.textContent = "ファイルを選んでください");
  const auth = credentials(); if (!auth) return;
  const data = new FormData(); data.append("file", input.files[0]);
  status.textContent = "Uploading...";
  const response = await fetch("upload", { method: "POST", headers: { Authorization: auth }, body: data });
  const result = await response.json().catch(() => ({}));
  if (!response.ok) return (status.textContent = `Upload failed: ${result.error || response.status}`);
  await loadFiles(auth); status.textContent = `Uploaded: ${result.path}`;
};
document.querySelector("#refresh").onclick = async () => {
  const auth = credentials(); if (!auth) return;
  try { await loadFiles(auth); } catch (error) { status.textContent = `Load failed: ${error.message}`; }
};
document.querySelector("#download").onclick = async () => {
  const name = list.value; if (!name) return (status.textContent = "ファイルを選んでください");
  const auth = credentials(); if (!auth) return;
  const response = await fetch(`files/${encodeURIComponent(name)}`, { headers: { Authorization: auth } });
  if (!response.ok) return (status.textContent = "Download failed");
  const url = URL.createObjectURL(await response.blob()); const link = Object.assign(document.createElement("a"), { href: url, download: name });
  link.click(); URL.revokeObjectURL(url);
};
