# Application

The Agex website: a static site with plain HTML, CSS and JavaScript, and no build step.

```text
application/website/
├── index.html, about.html, products.html, contact.html
├── privacy.html, terms.html, on-the-way.html, 404.html
├── css/style.css
├── js/main.js
└── assets/          SVG illustrations
```

Agex, its products, reviews and contact details are placeholders.

## Deploy

Ansible copies `website/` to `/var/www/agex` on the web server (see [configuration](../configuration/README.md)). A push to `main` that changes the site deploys it to dev.

| Environment | URL |
|---|---|
| dev | https://agex-dev.localhostshinn.xyz |
| prod | https://agex.localhostshinn.xyz |

## Preview Locally

```bash
python3 -m http.server 8000 -d application/website
```

Then open http://localhost:8000.
