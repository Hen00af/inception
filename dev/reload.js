// Development-only live reload. Compare contents to catch same-size saves.
(() => {
  const paths = ["index.html", "script.js", "style.css"];
  let previous;
  async function check() {
    try {
      const contents = await Promise.all(paths.map(async path => {
        const response = await fetch(`/static/${path}`, { cache: "no-store" });
        if (!response.ok) throw new Error(`Cannot read ${path}`);
        return response.text();
      }));
      const current = JSON.stringify(contents);
      if (previous !== undefined && previous !== current) {
        window.location.reload();
        return;
      }
      previous = current;
    } catch {
      // Retry after temporary restarts or partially completed saves.
    }
    setTimeout(check, 1000);
  }
  check();
})();
