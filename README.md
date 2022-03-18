# Happy Prime Hosting Scripts

A set of rudimentary scripts used to automate tasks related to hosting in some way or another.

## Host configuration

Some scripts rely on a YAML formatted host configuration. One is not included with this repository to avoid accidental sharing of client data.

The current format of the `host-config.yml` file should be:

```
--
sites:
  -
    project: project
    ssh_host: hostname
    domain: domain.test
    path: /var/www/domain.test
	auto: false
  -
    project: otherproject
    ssh_host: othername
    domain: otherdomain.test
    path: www/otherdomain.test/public_html
	auto: true
```

Where `project` is relatively arbitrary, `ssh_host` is the configured SSH host in your `./ssh/config` file, `domain` is the actual domain of the site, `path` is the path on the server where WordPress is installed, and `auto` is whether plugins can be updated via script.

## Database backup

`npm run backup:db` is used to:

1. Create a daily database backup directory.
2. Loop through configured sites.
3. Export each site's WordPress database with WP-CLI.
4. Compress each site's WordPress database.
5. Transfer the database locally with `scp`.
6. Sync the daily database backup directory with B2.

## wp-content backup

`npm run backup:files` is used to:

1. Create a daily content backup directory.
2. Loop through configured sites.
3. Compress each site's `wp-content` directory into a tar file.
4. Transfer the files locally with `scp`.

This command runs a full backup for each site and does not handle incremental changes. This will result in a *lot* of data transfer.

## WordPress core, plugin, and theme version checks

`npm run check:updates` is used to:

1. Display the current WordPress version for each host.
2. Log available plugin updates for each host in `plugin-updates/{host}-plugins.json`
3. Log available theme updates for each host in `theme-updates/{host}-themes.json`
    * These are relatively unimportant to us as all themes are custom and deployed in other ways.

`npm run issue:updates` is used to process the JSON files in `plugin-updates/` and open a new GitHub issue with a list of tasks corresponding with each available update.

* A `bot-token` file must exist in your working directory with a personal access token.

## Long term storage

Storage for our hosted backups is currently handled via BackBlaze's B2 service. If you have B2 configured locally, run:

`b2 sync yyyymmdd-db-files/ b2://happy-prime-hosting/yyyymmdd-db-files/`

If B2 is configured locally, this is also handled automatically in the database backup script.

## HTTPS certificate expiration

HTTPS certificates can be checked quickly using the [SSL Certification Expiration Checker](https://github.com/Matty9191/ssl-cert-check). That script is not included in this repository, but can be placed in your working directory or elsewhere on your computer.

1. Create an `ssldomains` file in your working directory.
2. Populate that file with a list of domain and port number, one entry per line (e.g. `happyprime.co 443`).
3. Run `npm run check:ssl` to generate a report of certificate status.
