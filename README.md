*This project has been created as part of the 42 curriculum by omizin.*

# Inception

## 1. Description
The **Inception** project is a major milestone in the 42 Network System Administration branch. The goal is to broaden personal knowledge by using **Docker** to virtualize a complete infrastructure. 

The project involves setting up a multi-container architecture containing:
* A web server (Nginx with TLS).
* A WordPress site (PHP-FPM).
* A database (MariaDB).
* Bonus services: Redis, Adminer, FTP, Portainer, and a Static Website.

Every service runs in its own dedicated container, built from a custom Dockerfile using a minimal base image (Debian Bookworm-slim).

---

## 2. Project Design Choices

### Docker & Sources
Each service in this repository is built from scratch. We do not use pre-made images from Docker Hub (except for the base OS). This approach ensures full control over the configuration, security patches, and minimal image size.

### Technical Comparisons

| Feature | Choice A | Choice B | Why we chose B / Difference |
| :--- | :--- | :--- | :--- |
| **Virtualization** | **Virtual Machines** | **Docker** | VMs virtualize hardware and run a full OS kernel. Docker virtualizes the OS, sharing the host kernel, making it lightweight and faster. |
| **Security** | **Env Variables** | **Secrets** | Env variables are visible in `docker inspect`. Secrets are encrypted/hidden and only mounted into the container at runtime. |
| **Networking** | **Host Network** | **Bridge Network** | Host network exposes all ports to the host. Bridge (Inception Network) isolates containers, only allowing traffic through Nginx. |
| **Persistence** | **Docker Volumes** | **Bind Mounts** | Volumes are managed by Docker. Bind Mounts link a specific host path (e.g., `/home/data`) to the container, which is a project requirement. |

---

## 3. Instructions

### Prerequisites
* Linux environment (Debian/Ubuntu).
* Docker and Docker Compose installed.
* Sudo privileges.

### Execution
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SuPuHe/SuPuInception && cd SuPuInception
    ```
2.  **Setup Environment:**
    Create a `.env` file and a `secrets/` folder in `srcs/` as described in the `DEV_DOC.md`.
3.  **Launch the stack:**
    ```bash
    make
    ```
4.  **Access:**
    Open `https://omizin.42.fr` in your browser (after adding it to `/etc/hosts`).

---

## 4. Resources

### Documentation & Tutorials
* [Docker Documentation](https://docs.docker.com/): Official guide for Dockerfiles and Compose.
* [Nginx Admin's Guide](https://docs.nginx.com/): Best practices for TLS and Reverse Proxy.
* [WordPress CLI](https://make.wordpress.org/cli/handbook/): Used for automated WP installation.

### Use of AI (Artificial Intelligence)
* **Debugging Configs:** Fixing PHP-FPM connection issues between containers.
* **Script Optimization:** Refining the MariaDB entrypoint script for better error handling.
* **Documentation:** Assisting in structuring and formatting the Markdown files (`USER_DOC.md`, `DEV_DOC.md`, and this `README.md`).

---

## 5. Further Information
For more detailed information, please refer to the specific documentation files:
* `USER_DOC.md`: For end-users and site administrators.
* `DEV_DOC.md`: For developers and system maintainers.

---
*Created by SuPuHe*