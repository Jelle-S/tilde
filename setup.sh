#!/usr/bin/env bash

echo "🔄 Updating package lists..."
sudo apt-get update
echo "✅ Package lists updated."

# Add repositories if not already present
echo "🔧 Checking for required PPAs..."
if ! grep -q "^deb http://ppa.launchpad.net/ondrej/php/ubuntu " /etc/apt/sources.list.d/*; then
    sudo add-apt-repository ppa:ondrej/php -y
    echo "➕ Added Ondrej PHP PPA."
fi
if ! grep -q "^deb http://ppa.launchpad.net/ondrej/apache2/ubuntu " /etc/apt/sources.list.d/*; then
    sudo add-apt-repository ppa:ondrej/apache2 -y
    echo "➕ Added Ondrej Apache2 PPA."
fi

# Install packages that are idempotent with apt
echo "📦 Installing base packages..."
sudo apt-get install -y mysql-server apache2 zip unzip gzip bzip2 xz-utils tar rbenv libnss3-tools build-essential autoconf automake libtool nasm pkg-config
echo "✅ Base packages installed."

echo "📦 Installing PHP packages..."
sudo apt-get install -y php8.3-cli php8.3-common php8.3-curl php8.3-gd php8.3-imap php8.3-intl php8.3-ldap php8.3-mbstring php8.3-mysql php8.3-sqlite3 php8.3-xml php8.3-xsl php8.3-zip php8.3-bcmath php8.3-Imagick php8.3-igbinary php8.3-gmp libapache2-mod-php8.3
echo "✅ PHP packages installed."

# Enable Apache modules idempotently
echo "⚠️ Enabling Apache modules: vhost_alias, rewrite, ssl..."
sudo a2enmod vhost_alias || true
sudo a2enmod rewrite || true
sudo a2enmod ssl || true
sudo a2enmod php8.3 || true
echo "✅ Apache modules enabled."

sudo systemctl reload apache2
echo "🔄 Apache configuration reloaded."

# Install remaining packages
echo "🎨 Installing Neovim..."
sudo apt-get install -y neovim
echo "✅ Neovim installed."

read -p "✉️ Enter your email address for your SSH key: " mail_address

# Only generate SSH key if not existing
ssh_key_path="$HOME/.ssh/id_ed25519"
if [ ! -f "$ssh_key_path" ]; then
    echo "🔑 Generating SSH key..."
    ssh-keygen -t ed25519 -C "$mail_address" -f "$ssh_key_path" -N ""
    echo "🔑 SSH key generated at $ssh_key_path."
else
    echo "🔑 SSH key already exists, skipping generation."
fi


sudo apt-get install -y git
sudo apt-get install -y bash-completion
echo "🚀 Git and bash-completion installed."

# Install composer only if not present
if [ ! -f /usr/local/bin/composer ]; then
    echo "🎵 Installing Composer..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer
    echo "✅ Composer installed."
else
    echo "🎵 Composer already installed, skipping."
fi

# Install mkcert if not present
if ! command -v mkcert &> /dev/null; then
    echo "📝 Installing mkcert..."
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
    chmod +x mkcert-v*-linux-amd64
    sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    echo "✅ mkcert installed."
else
    echo "📝 mkcert already installed, skipping."
fi

# Install nvm if not present
if [ ! -d "$HOME/.nvm" ]; then
    echo "🎩 Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    echo "✅ nvm installed."
else
    echo "🎩 nvm already installed, skipping."
fi

# Install dbeaver-ce if not present
if ! snap list | grep -q dbeaver-ce; then
    echo "🖥️ Installing dbeaver-ce..."
    sudo snap install dbeaver-ce
    echo "✅ dbeaver-ce installed."
else
    echo "🖥️ dbeaver-ce already installed, skipping."
fi

# Handle MySQL root password change idempotently
echo "🔐 Setting MySQL root password..."
read -s -p "🔑 Enter new MySQL root password: " new_password
echo
read -s -p "🔑 Confirm new MySQL root password: " confirm_password
echo

if [ "$new_password" != "$confirm_password" ]; then
    echo "❌ Error: Passwords do not match."
    exit 1
fi

# Only proceed if password has changed successfully
if ! sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${new_password}';"; then
    echo "❌ Failed to update MySQL root password."
    exit 1
fi
echo "✅ MySQL root password updated successfully."
unset new_password confirm_password
