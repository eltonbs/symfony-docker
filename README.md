# Symfony Docker

A [Docker](https://www.docker.com/) based development runtime for the [Symfony](https://symfony.com) web framework.\
Includes PHP FPM, Nginx, and MySQL services, and XDebug.

## Getting Started

1. [Install Docker](https://docs.docker.com/get-docker/).
2. [Install Docker Compose](https://docs.docker.com/compose/install/).
3. Download or clone this skeleton.
    - Optional: If you clone, remove the .git directory. Run `rm -rf .git`.
4. Go into the project directory.
5. Build images: `docker-compose build`
6. Create a new Symfony application:
    - Optional: Set `SYMFONY_VERSION` environment variable. Ex: Run `SYMFONY_VERSION=^5.4`.
    ```
    # run this if you are building a traditional web application
    docker-compose run --rm php composer create-project symfony/skeleton:"$SYMFONY_VERSION" --no-interaction tmp && cp -Rp tmp/. . && sudo rm -rf tmp
    docker-compose run --rm php composer require webapp --no-interaction

    # run this if you are building a microservice, console application or API
    docker-compose run --rm php composer create-project symfony/skeleton:"$SYMFONY_VERSION" --no-interaction tmp && cp -Rp tmp/. . && sudo rm -rf tmp
    docker-compose run --rm php composer require symfony/orm-pack --no-interaction
    docker-compose run --rm php composer require --dev symfony/maker-bundle
    ```
7. Configure the `DATABASE_URL` environment variable in `.env`.
    ```
    sed -i -e '/# DATABASE_URL=/d;' -e 's|^DATABASE_URL=".*"|DATABASE_URL="mysql://db_user:ChangeMe@database:3306/app?serverVersion=8.0"|' .env
    ```
8. Set yourself as owner of the project files that were created by the docker container.
   ```
   docker-compose run --rm php chown -R $(id -u):$(id -g) .
   ```
9. Run images: `docker-compose up`
10. Open `http://localhost` in your web browser.
11. Run `docker-compose down --remove-orphans` to stop the Docker containers.

### Installing on an Existing Project

- Download this skeleton.
- Copy the Docker-related files from the skeleton to your existing project:
```
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
