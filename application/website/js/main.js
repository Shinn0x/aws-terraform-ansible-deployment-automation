// Agex site script (shared by every page).
// 1. Loads the popover polyfill, only in browsers that lack the Popover API.
// 2. Shows the nav links inline when they fit on one row, and folds them behind
//    the Menu button when they don't. Without this script the menu stays folded,
//    which still works.
// 3. Filters the products page by category.
// 4. Counts up the reliability figures on the home page.
//
// The site is static: there are no forms or accounts, and nothing is sent anywhere.
// Scroll animations are pure CSS (see css/style.css) and need no script.

if (!Object.hasOwn(HTMLElement.prototype, "popover")) {
  const polyfill = document.createElement("script");
  polyfill.src = "https://unpkg.com/@oddbird/popover-polyfill@0.7.3/dist/popover.iife.min.js";
  document.head.append(polyfill);
}

// ---------- Responsive nav ----------

const header = document.querySelector(".site-header");
const inner = header?.querySelector(".header-inner");
const menu = document.getElementById("site-menu");

if (header && inner && menu) {
  let lastWidth = 0;

  // :is() keeps this from throwing where :popover-open is unknown (polyfill uses a class).
  const isOpen = () => menu.matches(":is(:popover-open, .\\:popover-open)");

  function layout(force = false) {
    const width = inner.clientWidth;
    const grew = width > lastWidth;
    lastWidth = width;

    // While folded, only re-measure when the header got wider. Unfolding just to
    // measure on every shrink would make the layout flicker.
    if (!force && !header.classList.contains("is-wide") && !grew) return;

    const wasOpen = isOpen();

    // Try the inline layout and see whether the row overflows.
    header.classList.add("is-measuring", "is-wide");
    menu.removeAttribute("popover");
    const fits = inner.scrollWidth <= inner.clientWidth;

    if (!fits) {
      header.classList.remove("is-wide");
      menu.setAttribute("popover", "auto");
      // Removing the attribute closed the menu, so reopen it if it was open.
      if (wasOpen) menu.showPopover();
    }

    requestAnimationFrame(() => header.classList.remove("is-measuring"));
  }

  const observer = new ResizeObserver(() => layout());
  observer.observe(header);
  observer.observe(menu);

  // Web fonts change the width of the links, so measure again once they load.
  document.fonts?.ready.then(() => layout(true));

  // Close the folded menu after a link is chosen (most links jump within a page).
  menu.addEventListener("click", (event) => {
    if (event.target.closest("a") && menu.hasAttribute("popover") && isOpen()) {
      menu.hidePopover();
    }
  });
}

// ---------- Product filters (products.html) ----------

const filters = document.querySelector("[data-filters]");

if (filters) {
  const products = [...document.querySelectorAll("[data-category]")];
  const count = document.querySelector("[data-count]");
  filters.hidden = false; // the chips only make sense with the script running

  filters.addEventListener("click", (event) => {
    const chosen = event.target.closest("button[data-filter]");
    if (!chosen) return;

    for (const button of filters.querySelectorAll("button[data-filter]")) {
      button.setAttribute("aria-pressed", String(button === chosen));
    }

    const filter = chosen.dataset.filter;
    let shown = 0;
    for (const product of products) {
      const match = filter === "all" || product.dataset.category === filter;
      product.hidden = !match;
      if (match) shown++;
    }

    if (count) count.textContent = `Showing ${shown} ${shown === 1 ? "product" : "products"}`;
  });

  // Links such as products.html?c=cloud open with that filter already chosen.
  const preset = new URLSearchParams(location.search).get("c");
  filters.querySelector(`button[data-filter="${CSS.escape(preset ?? "")}"]`)?.click();
}

// ---------- Count-up figures (home page, reliability section) ----------
// The real figure is in the HTML, so without the script, or with reduced motion,
// it simply shows. Screen readers get the final figure from a hidden copy.

const counters = document.querySelectorAll("[data-count-up]");

if (counters.length && matchMedia("(prefers-reduced-motion: no-preference)").matches) {
  const updaters = new Map();

  for (const el of counters) {
    const text = el.textContent.trim();
    const match = text.match(/[\d.,]+/);
    if (!match) continue;

    const raw = match[0];
    const target = Number(raw.replaceAll(",", ""));
    if (target < 10) continue; // "0 years, 1 years, 2 years" adds nothing; show it as is

    const decimals = raw.includes(".") ? raw.split(".")[1].length : 0;
    const format = new Intl.NumberFormat("en-US", {
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals,
      useGrouping: raw.includes(","),
    });
    const before = text.slice(0, match.index);
    const after = text.slice(match.index + raw.length);

    const label = document.createElement("span");
    label.className = "sr-only";
    label.textContent = text;
    const shown = document.createElement("span");
    shown.setAttribute("aria-hidden", "true");
    shown.textContent = before + format.format(0) + after;
    el.replaceChildren(label, shown);

    updaters.set(el, (progress) => {
      shown.textContent = before + format.format(target * progress) + after;
    });
  }

  // Count once, when most of the figure is on screen.
  const observer = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      observer.unobserve(entry.target);
      const update = updaters.get(entry.target);
      const start = performance.now();
      const step = (now) => {
        const t = Math.min((now - start) / 1400, 1);
        update(1 - (1 - t) ** 3); // ease out
        if (t < 1) requestAnimationFrame(step);
      };
      requestAnimationFrame(step);
    }
  }, { threshold: 0.6 });

  for (const el of updaters.keys()) observer.observe(el);
}
