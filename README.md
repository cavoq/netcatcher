# netcatcher
Monitor traffic in an environment and control via reverse shell.

## Environment

Environment variables should be set in a `.env` file in the root directory of the project. The following variables are required:

```bash
SERVER_ADDRESS=<SERVER_ADDRESS>
SERVER_PORT=<SERVER_PORT>
SERVER_USER=<SERVER_USER>
SERVER_PASSWORD=<SERVER_PASSWORD>

CAPTURE_PATH=<SERVER_PATH_TO_STORE_CAPTURES>
INTERVAL=<INTERVAL_TO_SEND_PACKETS>
```

## Usage

To start the server, run the following command after cloning the repository:

```bash
docker-compose up
```
