# CarGoRent – Windows Setup Guide

You need two programs (Git and Docker Desktop) and one command to run the whole system.
Plan about 45 minutes the first time, mostly downloads; after that it starts in under a minute.

## Before you start

| Need | Minimum | Why |
|---|---|---|
| Windows | Windows 10 (22H2) or 11, 64-bit | Docker Desktop needs WSL 2 |
| Memory | 8 GB RAM | The 8 containers use about 3.5 GB together |
| Disk | 10 GB free | Docker images (~4 GB) plus downloads |
| GitHub | Invitation accepted | The repositories are private |

Accept the GitHub invitation for each of the 8 `cargorent-*` repositories (check your email or
https://github.com/notifications). Without it, cloning fails with *Repository not found*.

## Step 1 – Install Git for Windows

1. Download from https://git-scm.com/download/win and install with the default options
   (keep *Git Credential Manager*; it handles the GitHub login).
2. Check: open PowerShell and run `git --version`.

## Step 2 – Install Docker Desktop

1. Admin PowerShell: `wsl --install`, then restart.
2. Install Docker Desktop from https://www.docker.com/products/docker-desktop/ (keep *Use WSL 2*).
3. Open Docker Desktop and wait for **Engine running**.
4. Check: `docker compose version`.

## Step 3 – Download the code

Use a short path such as `C:\cargorent` (not Desktop, Downloads or OneDrive):

```powershell
mkdir C:\cargorent
cd C:\cargorent
$repos = "infra","api-gateway","user-service","vehicle-service","booking-service","payment-service","notification-service","web"
foreach ($r in $repos) { git clone "https://github.com/rputhiyapurayil/cargorent-$r.git" }
```

The first clone opens a browser to sign in to GitHub. Afterwards `C:\cargorent` holds 8 `cargorent-*` folders.

## Step 4 – Start the app

```powershell
cd C:\cargorent\cargorent-infra
docker compose up --build -d
docker compose ps        # wait until all 8 are running (MySQL healthy)
```

The first build takes 10–20 minutes; later starts take under a minute.

## Step 5 – Open it

http://localhost:3000 · Admin: `admin@cargorent.com` / `Admin@123` · Customers: use **Sign up**.
Test card `4111 1111 1111 1111` succeeds, `4000 0000 0000 0002` is declined (test mode, no real money).

## Every day after that (from `C:\cargorent\cargorent-infra`)

| To | Command |
|---|---|
| Start | `docker compose up -d` |
| Stop (keeps data) | `docker compose down` |
| Status | `docker compose ps` |
| Logs | `docker compose logs -f booking-service` |
| Reset all data | `docker compose down -v` then `docker compose up -d` |

Get the latest code and rebuild:

```powershell
cd C:\cargorent
foreach ($r in (dir -Directory cargorent-*)) { git -C $r.FullName pull }
cd cargorent-infra
docker compose up --build -d
```

## Working on the code (optional)

- **Frontend:** install Node.js 20 LTS, then `cd C:\cargorent\cargorent-web`, `npm install`, `npm run dev` → http://localhost:5173 (uses the Docker backend, reloads on save).
- **A Java service:** edit it, then `docker compose up --build -d <service-name>` from `cargorent-infra`.
  Unit tests need JDK 21 + Maven: `mvn test` in that service's folder.
- **Swagger:** http://localhost:8081/swagger-ui.html … http://localhost:8085/swagger-ui.html (add headers `X-User-Id: 1`, `X-User-Role: ADMIN`).
- **Postman:** import `postman\CarGoRent.postman_collection.json` and run it top to bottom.
- **Share changes:** in the folder you edited: `git add -A`, `git commit -m "..."`, `git push`.

## Troubleshooting

| Problem | Fix |
|---|---|
| *Repository not found* on clone | Accept the GitHub invitation, sign in as the invited account, clone again. |
| `docker` not recognized / cannot connect to daemon | Open Docker Desktop, wait for *Engine running*, reopen PowerShell. |
| Virtualization / WSL error | Admin PowerShell: `wsl --update`, restart; else enable VT-x / AMD-V in BIOS. |
| *port is already allocated* (3000 / 8080) | Stop XAMPP/Tomcat, or create `cargorent-infra\.env` with `WEB_PORT=3001` and `GATEWAY_PORT=8090`. |
| Website says *Cannot reach the server* | Services still starting: wait a minute, check `docker compose ps`. |
| Container keeps restarting | `docker compose logs <service>`; usually low memory – close apps or raise Docker memory. |
| Slow or failed first build | Run `docker compose up --build -d` again; finished parts are reused. |
| Admin login fails / want a clean demo | `docker compose down -v`, then `docker compose up -d`. |
