### Deployment Checklist (Local -> GitHub -> Server Docker)

This is the single source of truth for making any change (especially UI) and deploying it safely from local to the server.

---

### Flow
- Make changes locally → Test locally → Commit & push to GitHub → Pull on server → Rebuild & restart containers → Verify.

---

### 1) Sync local with GitHub
Local terminal:
```bash
git checkout main
git pull origin main
```

---

### 2) Develop and test locally
Local terminal:
```bash
git status
python app.py
```
Open http://127.0.0.1:5000 and verify pages (including /meetings and Print View).

---

### 3) Commit and push to GitHub
Local terminal:
```bash
git add -A
git commit -m "feat(ui): describe your change"
git push origin main
```

---

### 4) Deploy on the server (pull + rebuild image + restart)
Server terminal:
```bash
cd ~/gemini-meeting-minute-new
git fetch --all
git reset --hard origin/main
docker-compose down
docker-compose up -d --build
```

---

### 5) Verify
Server terminal:
```bash
docker logs meeting-minutes-app-new --tail 100
```
Browser:
- Open live site and confirm the new UI is visible and healthy.

---

### 6) Database check (utility)
Server terminal:
```bash
docker exec -i meeting-minutes-app-new python3 - <<'PY'
from app import app, db
from sqlalchemy import inspect
with app.app_context():
    print('DB URI:', app.config['SQLALCHEMY_DATABASE_URI'])
    print('Models registered:', list(db.metadata.tables.keys()))
    inspector = inspect(db.engine)
    print('Tables before:', inspector.get_table_names())
    db.create_all()
    inspector = inspect(db.engine)
    print('Tables after:', inspector.get_table_names())
PY
```

---

### 7) Troubleshooting

- Endpoint mismatch (old PDF endpoint lingering):
Server terminal:
```bash
docker exec -it meeting-minutes-app-new bash -lc "grep -R 'generate_meeting_pdf' . || true"
docker exec -it meeting-minutes-app-new bash -lc "sed -i 's/generate_meeting_pdf/print_meeting/g' templates/meetings.html"
```

- Force a clean rebuild if UI doesn’t change after deploy:
Server terminal:
```bash
cd ~/gemini-meeting-minute-new
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

- Quick rollback to a previous commit:
Server terminal:
```bash
cd ~/gemini-meeting-minute-new
git checkout -f <commit-hash>
docker-compose down
docker-compose up -d --build
```

---

### Notes
- Docker compose mounts only images folders as volumes; application code is baked into the image. Always rebuild (`up -d --build`) after pulling new code.
- If you change `requirements.txt`, rebuilding the image is mandatory.
- Network `npm_default` is external and must exist on the host.
