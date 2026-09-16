# RSS Reader — Fullstack

Parent repository for the RSS Reader. The two apps live in their own
repositories and are included here as **git submodules**:

- [`rss_reader_backend`](https://github.com/) — FastAPI API (feeds, search, billing)
- [`rss_reader_ui`](https://github.com/) — React + Vite web UI + desktop wrapper

> Replace the links above with your actual repo URLs after publishing.

## Quickstart (contributors)

```bash
# Clone with submodules — without --recurse-submodules the app folders stay empty
git clone --recurse-submodules <this-repo-url>
cd <this-repo>

# Env (each app documents its keys in its own .env.example)
cp rss_reader_backend/.env.example rss_reader_backend/.env
cp rss_reader_ui/.env.example rss_reader_ui/.env.local
# then fill in GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET + JWT_SECRET_KEY

# Run the whole stack
docker compose up -d --build
```

- API: http://localhost:8080 (`/docs`)
- UI: http://localhost:5173

## Working with submodules

Each app is versioned independently — commit app changes **inside**
`rss_reader_backend/` / `rss_reader_ui/` and push those repos first. The
parent only records *which commit* of each app makes up a release:

```bash
# after pushing app changes, pin the new commits in the parent
git add rss_reader_backend rss_reader_ui
git commit -m "Pin backend X + frontend Y"
git push
```

After pulling the parent, sync the checkouts with:

```bash
git submodule update --init --recursive
```

## What lives where

| Path | Repo | Contents |
|---|---|---|
| `rss_reader_backend/` | submodule | API, workers, tests, ES configs |
| `rss_reader_ui/` | submodule | Web UI, desktop wrapper |
| `docker-compose.yml` | this repo | Full-stack local orchestration |
| `.env*` | never committed | Local secrets (gitignored) |

## License

MIT — see [LICENSE](LICENSE). The submodules carry the same license.
