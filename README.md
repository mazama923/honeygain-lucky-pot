# Honeygain Lucky Pot Automation

This project automates the Honeygain Lucky Pot collection process using Ruby and Ferrum. It schedules the action to run every 2 hours using Rufus-Scheduler.

## Features

- Automatically logs into the Honeygain dashboard.
- Clicks the "Open Lucky Pot" button when available.
- Logs all actions and errors.
- Runs in a Docker container.

## Requirements

- Honeygain account credentials (email and password).
- Docker installed on your machine (if running via Docker).
- Ruby (if running the script locally).

## Getting Started

### Environment Variables

Set the following environment variables:

| Variable            | Description                |
| ------------------- | --------------------------- |
| `HONEYGAIN_EMAIL`   | Your Honeygain email address. |
| `HONEYGAIN_PASSWORD`| Your Honeygain password.      |

### Running Locally

1. Ensure you have Ruby installed (3.3 or higher preferred).
2. Install required gems:
   ```bash
   gem install ferrum rufus-scheduler
   ```
3. Set the required environment variables (`HONEYGAIN_EMAIL` and `HONEYGAIN_PASSWORD`).
4. Start the script:
   ```bash
   ruby honeygain_lucky_pot.rb
   ```

### Running with Docker

   ```bash
    docker run -d --name honeygain --restart unless-stopped \
      -e HONEYGAIN_EMAIL=... -e HONEYGAIN_PASSWORD=... \
      benlexa/honeygain-lucky-pot:latest
   ```

Image available on [Docker Hub](https://hub.docker.com/repository/docker/benlexa/honeygain-lucky-pot/general).

### CasaOS and ZimaOS

Available in [mazimaos-appstore](https://github.com/mazama923/mazimaos-appstore).

```bash
https://github.com/mazama923/mazimaos-appstore/archive/refs/heads/main.zip
```

## Disclaimer

This project is for educational purposes only. Use at your own risk. Ensure compliance with Honeygain's Terms of Service while using this tool.
