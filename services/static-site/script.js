const file = document.querySelector("#file");
const status = document.querySelector("#status");
document.querySelector("#upload").onclick = async () => {
  if (!file.files[0]) return (status.textContent = "ファイルを選んでください");
  const user = prompt("FTP username");
  const password = prompt("FTP password");
  if (!user || !password) return;
  const data = new FormData(); data.append("file", file.files[0]);
  status.textContent = "Uploading...";
  const response = await fetch("upload", { method: "POST", headers: { Authorization: "Basic " + btoa(user + ":" + password) }, body: data });
  const result = await response.json().catch(() => ({}));
  status.textContent = response.ok ? `Uploaded: ${result.path}` : `Upload failed: ${result.error || response.status}`;
};
