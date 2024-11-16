# Symfony Docker

A [Docker](https://www.docker.com/) based development runtime for the [Symfony](https://symfony.com) web framework.\
Includes `PHP FPM`, `Nginx`, and `MySQL` services. PHP image contains `Node`, `Yarn`, `Composer`, `Symfony CLI`, and `Xdebug`.

## Getting Started

1. [Install Docker](https://docs.docker.com/get-docker/).
1. [Install Docker Compose](https://docs.docker.com/compose/install/).
1. Download or clone this skeleton and go into the project directory.
    - Optional: If you clone, remove the .git directory. Run `rm -rf .git`.
1. Set your UID and GID.
    - Check current user id, run the command `id`.
    ```shell
   id
   # uid=1000(user) gid=1000(user) groups=1000(user),4(adm),24(cdrom),27(sudo)
    ```
   - If `uid` or `gid` are different than `1000`, create a .env file with the returned values, e.g.:
   ```dotenv
   UID=1001
   GID=1001
   ```
1. Build images: `docker-compose build`
1. Create a new Symfony application:
    - Optional: Set `SYMFONY_VERSION` environment variable. For example, run `SYMFONY_VERSION=^5.4`.
    ```shell
    # run this if you are building a traditional web application
    docker-compose run --rm php composer create-project symfony/skeleton:"$SYMFONY_VERSION" --no-interaction tmp && cp -Rp tmp/. . && rm -rf tmp
    docker-compose run --rm php composer require webapp --no-interaction
   ```
   ```shell
    # run this if you are building a microservice, console application or API
    docker-compose run --rm php composer create-project symfony/skeleton:"$SYMFONY_VERSION" --no-interaction tmp && cp -Rp tmp/. . && rm -rf tmp
    docker-compose run --rm php composer require symfony/orm-pack --no-interaction
    docker-compose run --rm php composer require --dev symfony/maker-bundle
    ```
1. Configure the `DATABASE_URL` environment variable in `.env`.
    ```shell
    sed -i -e '/# DATABASE_URL=/d;' -e 's|^DATABASE_URL=".*"|DATABASE_URL="mysql://db_user:ChangeMe@database:3306/app?serverVersion=8.0"|' .env
    ```
1. Run images: `docker-compose up`
1. Open `http://localhost` in your web browser.
1. Run `docker-compose down --remove-orphans` to stop the Docker containers.

### Installing on an Existing Project

- Download this skeleton.
- Copy the Docker-related files from the skeleton to your existing project:
```shell
cp -r docker .dockerignore docker-compose.yml docker-compose.override.yml Dockerfile /destination/path/
```
- More information on enabling the Docker support of Symfony Flex: \
  [dunglas/symfony-docker: Installing on an Existing Project](https://github.com/dunglas/symfony-docker/blob/main/docs/existing-project.md#installing-on-an-existing-project).

## Debugging with Xdebug and PHPStorm

1. [Create a PHP debug server configuration](https://www.jetbrains.com/help/phpstorm/creating-a-php-debug-server-configuration.html)
   with the following parameters:
    - Name: `symfony` (must be the same as defined in `PHP_IDE_CONFIG`)
    - Host: `https://localhost` (or the one defined with `HOSTNAME`)
    - Port: `443`
    - Debugger: `Xdebug`
    - Select the `Use path mappings` checkbox and map the project root to the absolute path on the server: `/app`
        - IDE key: `PHPSTORM`

2. Use the **Xdebug extension**
   for [Chrome](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc)
   or [Firefox](https://addons.mozilla.org/en-US/firefox/addon/xdebug-ext-quantum/) if you want to debug on the
   browser (don't forget to configure it). If you don't want to use it, add on your request this query
   param: `XDEBUG_SESSION=PHPSTORM`.

3. On PHPStorm, click on `Start Listening for PHP Debug Connections` in the `Run` menu.

## More resources:

- [Makefile template](https://github.com/dunglas/symfony-docker/blob/main/docs/makefile.md): Provides some shortcuts for
  the most common tasks.

## Credits

Created by Elton Sousa. Based on Kévin Dunglas' [symfony-docker](https://github.com/dunglas/symfony-docker).
