Sure, here's a simplified version for easy copying:

# Chrome VNC Docker Container

This Docker container provides a headless Google Chrome browser accessible via VNC, managed by Supervisor.

## Usage

### Building the Docker Image

```bash
git clone <repository-url>
cd <repository-directory>
docker build --no-cache -t chrome-vnc .
```

### Running the Docker Container

```bash
docker run -d -p 5900:5900 --name chrome-vnc-container chrome-vnc
```

### Accessing the Chrome Browser

1. Use a VNC client to connect to `localhost:5900`.
2. When prompted for the password, enter `1234`.

## Configuration

- The VNC password is set to `1234` by default. You can change it by modifying the `x11vnc` command in the `Dockerfile`.
- Chrome command-line options and other configurations can be modified in the `supervisord.conf` file.

## License
This project is licensed under the MIT License.
