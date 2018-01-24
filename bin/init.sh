#!/bin/bash
if ! [ -e .env ] || ! [ -e artisan ]; then
	echo "Must be in Laravel project 5.5 with a valid .env"
	exit 1
fi
CANBEROOT=0
SUDOCMD=sudo
if sudo -l | grep "ALL$" > /dev/null; then
	CANBEROOT=1
elif [ "`whoami`" == "root" ]; then
	SUDOCMD=
	CANBEROOT=1
fi
if [ "$CANBEROOT" == "1" ]; then
	if [ "`which jq`" == "" ]; then
		$SUDOCMD apt install jq -y
	fi
	if [ "`which sponge`" == "" ]; then
		$SUDOCMD apt install moreutils -y
	fi
else
	echo "Need commands jq and sponge from moreutils."
	echo "Please contact your system administrator to install those applications."
	exit 1
fi

echo "Requiring afrittella/back-project..."
composer require afrittella/back-project

echo -n "Updating composer.json to get custom patches..."
cat composer.json | jq ' .repositories += {"backproject":{"type":"vcs","url":"https://github.com/shemgp/back-project.git"},"laravel-generator":{"type":"vcs","url":"https://github.com/shemgp/laravel-generator.git"},"adminlte-templates":{"type":"vcs","url":"https://github.com/shemgp/adminlte-templates.git"},"datagrid":{"type":"vcs","url":"https://github.com/shemgp/datagrid.git"},"boot-form":{"type":"vcs","url":"https://github.com/shemgp/bootstrap-form.git"}}' | sponge composer.json

cat composer.json | jq ' .require += {"afrittella/back-project": "dev-changes"}' | sponge composer.json

cat composer.json | jq ' . += {"minimum-stability": "dev"}' | sponge composer.json
echo "done"

echo "Getting patches.."
composer update
composer require doctrine/dbal brian2694/laravel-toastr
composer require "fxp/composer-asset-plugin:~1.3"
cat composer.json | jq ' .config += {"fxp-asset": { "installer-paths": {"bower-asset-library": "public/vendor/bower_components", "npm-asset-library": "public/vendor/npm_components"}}}' | sponge composer.json
composer require bower-asset/toastr

echo "Configuring back-project (1/3)..."
php artisan vendor:publish --provider="Afrittella\BackProject\BackProjectServiceProvider" --tag="config"

php artisan vendor:publish --provider="Prologue\Alerts\AlertsServiceProvider"

php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --tag="config"

php artisan vendor:publish --provider="Intervention\Image\ImageServiceProviderLaravel5"

sed -i -e "s#'permission'.*\$#'permission' => Afrittella\\\\BackProject\\\\Models\\\\Permission::class,#" config/laravel-permission.php
sed -i -e "s#'role'.*\$#'role' => Afrittella\\\\BackProject\\\\Models\\\\Role::class,#" config/laravel-permission.php

php artisan vendor:publish --provider="Afrittella\BackProject\BackProjectServiceProvider" --tag="adminlte"

php artisan vendor:publish --provider="Laravolt\Avatar\ServiceProvider"

php artisan vendor:publish --provider="Afrittella\BackProject\BackProjectServiceProvider" --tag="public"

php artisan vendor:publish --provider="Afrittella\BackProject\BackProjectServiceProvider" --tag="errors"

php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --tag="migrations"

sed -i -e "s#App\\\\User::class#Afrittella\\\\BackProject\\\\Models\\\\Auth\\\\User::class#g" config/auth.php
echo "done"

echo -n "Setting storage permissions..."
if [ "$CANBEROOT" == "1" ]; then
	if [ "$SUDOCMD" != "" ]; then
		echo ""
	fi
	$SUDOCMD chown shemgp:www-data storage -R
	$SUDOCMD chmod 775 storage -R
else
	chmod 777 storage -R
	echo "done"
fi

echo -n "Setting email in .env to log..."
sed -i .env -e 's#MAIL_HOST=.*#MAIL_HOST=smtp.gmail.com#g'
sed -i .env -e 's#MAIL_PORT=.*#MAIL_PORT=587#g'
sed -i .env -e 's#MAIL_DRIVER=.*#MAIL_DRIVER=log#g'
echo "done"

echo -n "Setting model user tracking to true..."
sed -i .env -e '/ENABLE_USER_TRACKING_MODEL.*/d'
sed -i .env -e '/APP_URL/a ENABLE_USER_TRACKING_MODEL=true'
echo "done"

echo -n "Configuring back-project (2/3)..."
if ! grep -i afrittella app/Http/Kernel.php > /dev/null; then
	sed -i -e "s#'guest'.*#'guest' => \\\\Afrittella\\\\BackProject\\\\Http\\\\Middleware\\\\RedirectIfAuthenticated::class,\n        'admin' => \\\\Afrittella\\\\BackProject\\\\Http\\\\Middleware\\\\Admin::class,\n        'role' => \\\\Afrittella\\\\BackProject\\\\Http\\\\Middleware\\\\Role::class,#" app/Http/Kernel.php
fi
echo "done"

echo "Running dump-autoload..."
composer dump-autoload

echo -n "Setting storage permissions again..."
if [ "$CANBEROOT" == "1" ]; then
	if [ "$SUDOCMD" != "" ]; then
		echo ""
	fi
	$SUDOCMD chown shemgp:www-data storage -R
	$SUDOCMD chmod 775 storage -R
else
	chmod 777 storage -R
	echo "done"
fi

echo "Configuring back-project (3/3).."
php artisan vendor:publish --all

find database/migrations/ -iname *permission_tables* | tail -n +2 | xargs rm > /dev/null
php artisan migrate

php artisan back-project:seed-permissions

php artisan back-project:seed-menus

echo ""
echo "You're all set!"
echo ""
echo "You may now register to create the first account."
echo ""
echo "Note: You have to have a valid MAIL_DRIVER setup or you may use MAIL_DRIVER=log."
echo "      If you use MAIL_DRIVER=log, then check storage/logs/laravel.log"
echo "      after registering to get the link to enable the first registrant."
echo ""
