#!/bin/zsh
set -e
cd "${0:A:h}"
rm -rf sandbox && mkdir sandbox && cd sandbox

mkdir -p webshop/src/components webshop/node_modules/react webshop/dist
cd webshop
git init -q
printf 'node_modules/\ndist/\n' > .gitignore
echo 26 > .node-version
echo '{ "name": "webshop", "scripts": { "dev": "echo dev server" } }' > package.json
echo '# Webshop' > README.md
echo 'export const Cart = () => "cart";' > src/components/Cart.jsx
echo 'export const Header = () => "header";' > src/components/Header.jsx
echo 'console.log("app");' > src/index.js
git add -A && git commit -qm "Initial commit"
echo 'export const Footer = () => "footer";' > src/components/Footer.jsx
git add -A && git commit -qm "Add footer"
echo 'module.exports = {}' > node_modules/react/index.js
echo 'bundle' > dist/bundle.js
echo '// TODO: checkout' >> src/components/Cart.jsx
echo '// sticky' >> src/components/Header.jsx && git add src/components/Header.jsx
echo 'export const Search = () => "search";' > src/components/Search.jsx
cd ..

mkdir legacy-api && echo 20 > legacy-api/.nvmrc
echo 'console.log("legacy", process.version)' > legacy-api/server.js

mkdir -p clients/acme/projects/2026/q4/secret-dashboard
echo "you found it" > clients/acme/projects/2026/q4/secret-dashboard/notes.txt

mkdir -p haystack/{a,b,c}/{one,two,three}
for d in haystack/*/*; do for i in {1..12}; do echo hay > "$d/file-$i.txt"; done; done
echo "🪡 you found the needle" > haystack/c/two/needle.md

mkdir -p archives/photos && echo pic > archives/photos/beach.jpg && echo pic > archives/photos/sunset.jpg
(cd archives && zip -qr photos.zip photos && tar -czf photos.tar.gz photos && rm -rf photos)

echo "✅ Sandbox ready: $PWD"
echo "   Open playground/README.md and start with Mission 1."
