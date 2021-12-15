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
  -
    project: otherproject
    ssh_host: othername
    domain: otherdomain.test
    path: www/otherdomain.test/public_html
```

Where `project` is relatively arbitrary, `ssh_host` is the configured SSH host in your `./ssh/config` file, `domain` is the actual domain of the site, and `path` is the path on the server where WordPress is installed.

## Database backup

`npm run backup:db` is used to:

1. Create a daily database backup directory.
2. Loop through configured sites.
3. Export each site's WordPress database with WP-CLI.
4. Compress each site's WordPress database.
5. Transfer the database locally with `scp`.
6. Sync the daily database backup directory with B2.

## WordPress core, plugin, and theme version checks

`npm run check:updates` is used to:

1. Check for available WordPress core updates.
2. Check for available plugin updates.
3. Check for available theme updates.

Ideally, most sites are configured to handle these automatically.

## Long term storage

Storage for our hosted backups is currently handled via BackBlaze's B2 service. If you have B2 configured locally, run:

`b2 sync yyyymmdd-db-files/ b2://happy-prime-hosting/yyyymmdd-db-files/`

If B2 is configured locally, this is also handled automatically in the database backup script.

## HTTPS certificate expiration

HTTPS certificates can be checked quickly using the [SSL Certification Expiration Checker](https://github.com/Matty9191/ssl-cert-check). That script is not included in this repository, but can be placed in your working directory or elsewhere on your computer.

1. Create an `ssldomains` file in your working directory.
2. Populate that file with a list of domain and port number, one entry per line (e.g. `happyprime.co 443`).
3. Run `npm run check:ssl` to generate a report of certificate status.
