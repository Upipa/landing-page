#!/bin/bash
set -e

# Variabili richieste a runtime (passate con docker run -e):
#   REPO_URL   - URL del repository (es. https://github.com/org/repo.git)
#   GIT_TOKEN  - Personal access token con permessi di push
#   GIT_USER   - Nome utente git (per il commit)
#   GIT_EMAIL  - Email git (per il commit)

echo "==> Configurazione git"
git config --global user.name  "${GIT_USER}"
git config --global user.email "${GIT_EMAIL}"

# Incorpora il token nell'URL per l'autenticazione HTTPS
REPO_URL_AUTH=$(echo "https://github.com/Upipa/landing-page" | sed "s|https://|https://${GIT_TOKEN}@|")

echo "==> Clone del repository"
git clone "${REPO_URL_AUTH}" /app
cd /app

echo "==> Ripristino pacchetti R (renv::restore)"
Rscript -e "renv::restore(prompt = FALSE)"

echo "==> Quarto render"
quarto render

echo "==> Push delle modifiche"
git add docs/
git diff --cached --quiet \
    && echo "Nessuna modifica da committare." \
    || (git commit -m "Aggiornamento automatico sito [$(date '+%Y-%m-%d %H:%M')]" && git push)

echo "==> Completato."
