# User Documentation: Inception Stack

This documentation provides an overview and management guide for the **Inception Project** infrastructure, a fully containerized web environment.

---

## 1. Services Provided

The stack runs as isolated microservices inside a dedicated Docker network.

- **Nginx:** Secure reverse proxy handling HTTPS traffic and SSL termination.
- **WordPress:** Main CMS running on PHP-FPM for dynamic content.
- **MariaDB:** Relational database storing site content, users, and configuration.
- **Redis:** In-memory object cache to improve WordPress performance.
- **Adminer:** Lightweight web interface for MariaDB administration.
- **Portainer:** Docker management dashboard for containers, images, and networks.
- **FTP (vsftpd):** Secure FTP service for managing files in the WordPress volume.
- **Static Site:** Separate HTML/CSS website served by its own container.

---

## 2. Starting and Stopping the Project

Infrastructure management is handled by the root `Makefile`.

### Start the Project

Build images, create persistent volumes, and run all containers in detached mode:

```bash
make
```

### Stop the Project

Stop all running containers without deleting volumes or data:

```bash
make stop
```

### Clean the Project

Stop containers and remove images, networks, and all persistent data volumes:

```bash
make fclean
```

---

## 3. Accessing the Services

Before opening any URL, add this line to your local `/etc/hosts`:

```text
127.0.0.1 omizin.42.fr
```

| Service | Access URL | Credentials Required |
|---|---|---|
| WordPress Site | https://omizin.42.fr | No (Public) |
| WordPress Admin | https://omizin.42.fr/wp-admin | Yes (WP Admin) |
| Adminer | https://omizin.42.fr/adminer | Yes (DB User) |
| Portainer | https://omizin.42.fr/portainer | Yes (Portainer Admin) |
| Static Website | http://omizin.42.fr/static | No (Public) |

---

## 4. Locating and Managing Credentials

This project follows secret-management best practices with Docker Secrets. Passwords are not hardcoded.

- **Secrets directory:** `secrets/`
- **Secret files:** `db_password.txt`, `db_root_password.txt`, `credentials.txt`, `user_credentials.txt`, `portainer_pass.txt`

### Modify Credentials

1. Update the corresponding file in `secrets/`.
2. Rebuild and restart the stack:

```bash
make re
```

---

## 5. Checking Service Health

Use the following checks to verify that the infrastructure is healthy.

### Container Status

```bash
docker ps
```

All expected containers should be in `Up` state.

### Verification Checklist

- **Nginx + WordPress:** Open `https://omizin.42.fr`. If the site loads, reverse proxy and PHP-FPM integration are working.
- **Database (MariaDB):** Log in to Adminer and verify tables (for example `wp_users`) are visible.
- **Redis Cache:**

```bash
docker exec -it redis redis-cli ping
```

Expected output:

```text
PONG
```

- **FTP Service:**

```bash
ftp omizin.42.fr
```

Successful authentication confirms FTP is operational.
