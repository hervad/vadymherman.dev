// Theme switch (design spec): AUTO → LIGHT → DARK → AUTO. Inlined in <head> by head.html, so it
// runs before the first paint: a saved choice is applied before anything is drawn (no white flash).
// "auto" means: no data-theme attribute, the CSS follows the OS (prefers-color-scheme).
(() => {
  const root = document.documentElement;
  root.classList.add("js"); // the switch is shown only when this script runs (see main.css)
  try {
    const saved = localStorage.getItem("theme");
    if (saved === "light" || saved === "dark") root.dataset.theme = saved;
  } catch (_) { /* storage blocked: stay on auto */ }

  const order = ["auto", "light", "dark"];
  const osDark = () => matchMedia("(prefers-color-scheme: dark)").matches;
  const looks = (t) => (t === "auto" ? (osDark() ? "dark" : "light") : t);

  document.addEventListener("click", (e) => {
    const button = e.target.closest(".theme");
    if (!button) return;
    const current = root.dataset.theme || "auto";
    const next = order[(order.indexOf(current) + 1) % order.length];
    const apply = () => {
      if (next === "auto") delete root.dataset.theme; else root.dataset.theme = next;
      try {
        if (next === "auto") localStorage.removeItem("theme"); else localStorage.setItem("theme", next);
      } catch (_) {}
    };
    // Circular reveal from the button, only when the colours really change and motion is welcome.
    if (!document.startViewTransition || looks(current) === looks(next) ||
        matchMedia("(prefers-reduced-motion: reduce)").matches) return apply();
    const r = button.getBoundingClientRect();
    const x = r.left + r.width / 2, y = r.top + r.height / 2;
    const radius = Math.hypot(Math.max(x, innerWidth - x), Math.max(y, innerHeight - y));
    document.startViewTransition(apply).ready.then(() => {
      root.animate(
        { clipPath: [`circle(0px at ${x}px ${y}px)`, `circle(${radius}px at ${x}px ${y}px)`] },
        { duration: 450, easing: "cubic-bezier(.4,0,.2,1)", pseudoElement: "::view-transition-new(root)" },
      );
    });
  });
})();
