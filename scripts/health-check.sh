#!/usr/bin/env bash
# Check that the website is up after a deploy.
# Usage: ./scripts/health-check.sh <URL>
set -euo pipefail

url="${1:-}"
url="${url%/}"
host="${url#https://}"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

[[ "$url" == https://* ]] || fail "usage: $0 https://<domain>"

# HTTPS returns 200 with a valid certificate. Retry while nginx reloads
code=$(curl -sS -o /dev/null -w '%{http_code}' --retry 5 --retry-delay 5 --retry-all-errors --max-time 10 "$url/") ||
  fail "could not connect to $url"
[[ "$code" == "200" ]] || fail "$url returned $code, expected 200"
echo "OK: $url returns 200 with a valid certificate"

# The page is the Agex site, not the nginx welcome page
body=$(curl -sS --max-time 10 "$url/")
grep -q "Agex" <<<"$body" || fail "$url does not look like the Agex site"
echo "OK: page is the Agex site"

# HTTP redirects to HTTPS
read -r code location < <(curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' --max-time 10 "http://$host/")
[[ "$code" == "301" && "${location%/}" == "$url" ]] ||
  fail "http://$host returned $code to '${location:-nothing}', expected 301 to $url"
echo "OK: http://$host redirects to HTTPS"
