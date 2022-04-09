# foscam-viewer

Web application for viewing and controlling a Foscam IP camera.

![Screenshot](/screenshot.png?raw=true)

## Supported cameras

I wrote this for use with the Foscam R4S. That's the only camera I've
tested it with. It may work with others if they use [the same API](/Foscam-IPCamera-CGI-User-Guide-AllPlatforms-2015.11.06.pdf?raw=true).

## Features

This app is very simple and only does a few things.

* Live view of the camera (MJPEG stream)
* Buttons to move the camera around
* Authentication based on the camera's users (more on that below)

## Authentication

The app doesn't have its own list of users and passwords. Instead, it passes
that through to the camera. So you can just use your existing camera user(s)
and password(s) with this app.

Viewing the camera's images requires only 'visitor' privilege, but for the
movement buttons to work the user must at least have 'operator' privilege.

## Configuration

You can set these options in `foscam_viewer.yml`:

### secrets

A list of secrets for signed cookies. Use a random string. It's a list in case
you ever want to change the secret while still honoring cookies signed with an
old one. Cookies get signed by the first secret in the list, but those signed
by any secret in the list are accepted.

### session_expiration_seconds (optional)

Default: 3600

How long before cookies expire. After this amount of time, clients will have
to log in again.

### camera_baseurl

Where to find your camera on the network. This is the non-HTTPS port, which
if you didn't change it from the default is port 88.

Example: `http://192.168.100.123:88`

### mjpeg_refresh_seconds

When clients view the video, they're watching an MJPEG stream, which is just
a bunch of JPEG images pushed to them periodically.

This setting controls how frequently to fetch a live camera image and push it
to the client, which for the client is how frequently the image updates when
watching the stream.

### motion_seconds (optional)

Default: 0.5

The camera's API for motion lets you start movement in any direction and
separately stop movement. The motion buttons on this app are supposed to "move
a little" in each direction. When you click them, the app tells the camera to
start moving, then after this amount of time tells it to stop moving. (Because
of this being two calls to the camera's API, the amount of movement you get
from each button press isn't always exactly the same.)

### base_path (optional)

If you put this application behind a reverse proxy, and you're not proxying
an entire domain/subdomain to it, set this to the base path you're proxying
so that the app can make self-referencing URLs correctly.

For example, if you proxy `http://www.example.com/camera` to this application,
set `base_path` to `/camera`.

In the sample configurations, this setting is in a separate file with
`production` in the name. You can put everything in one file, but this helps
when you run the app using Mojolicious' development web server while
developing.

## Installation

You need the [Mojolicious](https://www.mojolicious.org/) Perl module
installed in order to run this application.

### Simple setup

This will run using Mojolicious' built-in web server. This is useful
for testing it out to see if the configuration is correct.

```
git clone https://github.com/jlouder/foscam-viewer.git
cd foscam-viewer
cp foscam_viewer.yml.sample foscam_viewer.yml
vi foscam_viewer.yml   # change config values to your liking
script/foscam-viewer daemon -l 'http://*:8080'
```

### A "production" deployment

If you want actual users to use this, you probably want to use one of the
[deployment methods from the Mojolicious cookbook](https://docs.mojolicious.org/Mojolicious/Guides/Cookbook#DEPLOYMENT).

There are lots of options there. Personally, I use Mojolicious' Hypnotoad
server behind an Apache reverse proxy.

### Updating

This repo is designed so that you can deploy the cloned repo directly. Then,
to get updates, simply `git pull`.
