# Developer Documentation: Inception Stack

This document explains how to set up, build, run, manage, and persist the Inception infrastructure from a clean machine.

---

## 1. Prerequisites

Before working with the project, make sure the following tools and requirements are available:

- Docker Engine installed and running.
- Docker Compose v2 available through the `docker compose` command.
- `make` installed.
- `sudo` access, because `make fclean` removes the persistent data directory under `/home/omizin/data`.
- The local host name `omizin.42.fr` mapped to `127.0.0.1` in `/etc/hosts`.

Recommended host entry:

```text
127.0.0.1 omizin.42.fr
```

---

## 2. Configuration Files and Secrets

The stack is configured through the following files and directories:

- `Makefile` at the project root: creates the data directories and launches the stack.
- `srcs/docker-compose.yml`: defines all services, networks, secrets, and bind-mounted volumes.
- `secrets/`: stores Docker Secret source files used by the containers.

### Secret Files

The compose file expects these files to exist under `secrets/`:

- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/credentials.txt`
- `secrets/user_credentials.txt`
- `secrets/portainer_pass.txt`

### Environment Variables

The stack also depends on environment variables consumed by `srcs/docker-compose.yml`. These values can be provided through your shell environment or a `.env` file used by Docker Compose.

At minimum, review and define the variables used by the compose file, such as:

- `DOMAIN_NAME`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `WP_ADMIN_EMAIL`
- `WP_USER_EMAIL`
- `WP_USER_ROLE`
- `CERT_PATH`
- `KEY_PATH`
- `NGINX_HTTPS_PORT`
- `WORDPRESS_FPM_PORT`
- `MARIADB_PORT`
- `REDIS_PORT`
- `FTP_PORT`
- `FTP_PASSIVE_MIN`
- `FTP_PASSIVE_MAX`
- `PORTAINER_PORT`
- `STATIC_SITE_PORT`
- `ADMINER_PORT`

If you start from a clean workspace, create or update the environment file before running the stack.

---

## 3. Set Up the Environment From Scratch

The `make` workflow expects the data directories and secrets to be ready.

1. Install Docker, Docker Compose, and `make`.
2. Add `127.0.0.1 omizin.42.fr` to `/etc/hosts`.
3. Create the required secret files under `secrets/`.
4. Provide the required Compose environment variables.
5. Let the project create the persistent bind-mount directories by running the setup step through `make`.

The `setup` target creates these host directories automatically:

- `/home/omizin/data/mariadb`
- `/home/omizin/data/wordpress`
- `/home/omizin/data/portainer`

---

## 4. Build and Launch the Project

The normal entry point is the root `Makefile`.

### Preferred Launch Command

```bash
make
```

This runs the `setup` target first and then executes:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

### What Happens During Startup

- The bind-mount directories under `/home/omizin/data` are created.
- Docker images are rebuilt when needed.
- The services are started in detached mode on the `inception_network` bridge network.

---

## 5. Manage Containers and Volumes

The Makefile provides the main lifecycle commands:

### Stop Running Containers

```bash
make stop
```

Stops containers without removing networks, images, or data.

### Remove Containers and Network State

```bash
make down
```

Stops and removes the compose stack resources, but keeps local images and the bind-mounted data directories.

### Remove Images and Unused Docker Resources

```bash
make clean
```

Runs `make down` and then prunes Docker images and unused resources with `docker system prune -a --force`.

### Full Cleanup

```bash
make fclean
```

Runs `make clean` and then removes the persistent host data directory:

```bash
/home/omizin/data
```

### Rebuild Everything

```bash
make re
```

Runs the full cleanup and starts the stack again from scratch.

### Useful Docker Compose Commands

If you need lower-level inspection, use the compose file directly:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml exec wordpress bash
```

---

## 6. Data Storage and Persistence

The project uses bind-mounted volumes backed by host directories, so container recreation does not erase data.

### Persistent Data Locations

- MariaDB data is stored in `/home/omizin/data/mariadb`.
- WordPress files are stored in `/home/omizin/data/wordpress`.
- Portainer data is stored in `/home/omizin/data/portainer`.

### Bind-Mounted Compose Volumes

The compose file maps these named volumes to the host paths above:

- `mariadb_data` -> `/home/omizin/data/mariadb`
- `wordpress_data` -> `/home/omizin/data/wordpress`
- `portainer_data` -> `/home/omizin/data/portainer`

### Persistence Behavior

- Rebuilding images does not delete the data stored in these directories.
- `make stop` and `make down` keep the data intact.
- `make fclean` removes the data directory, so all persistent database and application state is lost.
- The WordPress volume is shared by the `wordpress`, `nginx`, and `ftp` services, so file changes made through one service are visible to the others.

---

## 7. Quick Troubleshooting Checklist

If the stack does not start correctly, check the following:

- Verify that all files in `secrets/` exist.
- Verify that the required environment variables are defined.
- Verify that `/home/omizin/data` exists or can be created by the current user.
- Check container state with `docker ps`.
- Review service logs with `docker compose -f srcs/docker-compose.yml logs -f`.
