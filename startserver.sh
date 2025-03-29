#!/bin/bash

ENV_FILE=".env"
EXAMPLE_FILE=".env.example"

if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$EXAMPLE_FILE" ]; then
        cp "$EXAMPLE_FILE" "$ENV_FILE"
        if [ $? -eq 0 ]; then
            echo "Created $ENV_FILE successfully!"
        else
            echo "Failed to copy $EXAMPLE_FILE to $ENV_FILE"
            exit 1
        fi
    else
        echo "Failed to find $EXAMPLE_FILE. Cannot create $ENV_FILE"
        exit 1
    fi
else
    echo "$ENV_FILE existed, skipping."
fi

APP_KEY=$(grep "^APP_KEY=" "$ENV_FILE" | cut -d '=' -f 2-)
if [ -z "$APP_KEY" ]; then
    echo "APP_KEY not found, generating..."
    php artisan key:generate
    if [ $? -eq 0 ]; then
        echo "Successfully generated new APP_KEY"
    else
        echo "Error: Failed to generate APP_KEY"
        exit 1
    fi
else
    echo "APP_KEY generated, skipping..."
fi

echo "Updating node modules and rebuilding app assets..."

if [ -f "yarn.lock" ] && command -v yarn >/dev/null 2>&1; then
    echo "Yarn detected."
    INSTALL_CMD="yarn"
    UPDATE_CMD="yarn upgrade"
    BUILD_CMD="yarn build"
elif [ -f "pnpm-lock.yaml" ] && command -v pnpm >/dev/null 2>&1; then
    echo "pnpm detected."
    INSTALL_CMD="pnpm install"
    UPDATE_CMD="pnpm update"
    BUILD_CMD="pnpm build"
elif [ -f "package-lock.json" ] || command -v npm >/dev/null 2>&1; then
    echo "npm detected."
    INSTALL_CMD="npm install"
    UPDATE_CMD="npm update"
    BUILD_CMD="npm run build"
else
    echo "Error: No supported package manager (npm, yarn, or pnpm) found."
    exit 1
fi

if [ -d "node_modules" ]; then
    echo "node_modules exists. Running update command: $UPDATE_CMD"
    $UPDATE_CMD
    if [ $? -ne 0 ]; then
        echo "Error: Update failed."
        exit 1
    fi
else
    echo "node_modules not found. Running install command: $INSTALL_CMD"
    $INSTALL_CMD
    if [ $? -ne 0 ]; then
        echo "Error: Installation failed."
        exit 1
    fi
fi

if grep -q '"build":' "package.json"; then
    echo "Running build command: $BUILD_CMD"
    $BUILD_CMD
    if [ $? -ne 0 ]; then
        echo "Error: Build failed."
        exit 1
    fi
    echo "Build completed successfully."
else
    echo "Warning: No 'build' script found in package.json."
    echo "Available scripts:"
    grep -oP '"\w+":\s*"[^"]+"' package.json | sed 's/": */: /'
    exit 1
fi

if command -v composer >/dev/null 2>&1; then
    if [ -d "vendor" ]; then
        echo "vendor folder exists. Running: composer update"
        composer update
        if [ $? -ne 0 ]; then
            echo "Error: Composer update failed."
            exit 1
        fi
    else
        echo "vendor folder not found. Running: composer install"
        composer install
        if [ $? -ne 0 ]; then
            echo "Error: Composer install failed."
            exit 1
        fi
    fi
else
    echo "Error: Composer not found. Please install Composer using your package manager or go to https://getcomposer.org/download/ to install it manually"
    exit 1
fi

if command -v php >/dev/null 2>&1; then
    php artisan serve
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start the server with 'php artisan serve'."
        exit 1
    fi
else
    echo "Error: PHP not found. Please install PHP using your package manager or visit https://www.php.net/manual/en/install.php."
    exit 1
fi
