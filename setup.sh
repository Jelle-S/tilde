#!/usr/bin/env bash 

sudo apt-get update
sudo add-apt-repository ppa:ondrej/php -y
sudo add-apt-repository ppa:ondrej/apache2 -y
sudo apt-get install mysql-server apache2
sudo apt-get install zip unzip gzip bzip2 xz-utils tar rbenv libnss3-tools -y
sudo apt-get install php8.3-cli php8.3-common php8.3-curl php8.3-gd php8.3-imap php8.3-intl php8.3-ldap php8.3-mbstring php8.3-mysql php8.3-sqlite3 php8.3-xml php8.3-xsl php8.3-zip php8.3-bcmath php8.3-Imagick php8.3-igbinary php8.3-gmp -y
sudo a2enmod vhost_alias
sudo a2enmod rewrite
sudo systemctl reload apache2
read -s -p "Enter new MySQL root password: " new_password
echo

read -s -p "Confirm new MySQL root password: " confirm_password
echo

if [ "$new_password" != "$confirm_password" ]; then
    echo "Error: Passwords do not match."
    exit 1
fi

sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${new_password}';"
unset new_password confirm_password
if [ $? -eq 0 ]; then
    echo "MySQL root password updated successfully."
else
    echo "Failed to update MySQL root password."
fi

sudo apt-get install neovim
read -p "Enter your mail adress for your SSH key" mail_address
ssh-keygen -t ed25519 -C "${mail_address}"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

sudo apt-get install git
sudo apt-get install bash-completion
read -p "Enter your Git user name: " git_user_name

git config --global user.name "$git_user_name"
git config --global user.email "$mail_address"

while true; do
    read -p "Please confirm you've added your public key to your GitHub account [Y/n]: " answer
    case "$answer" in
        [Yy]) 
            echo "✅ Confirmed, proceeding..."
            break
            ;;
        [Nn])
            echo "❌ You must add your key first. Try again."
            ;;
        "")  # Treat empty input as "yes"
            echo "✅ Confirmed (default yes), proceeding..."
            break
            ;;
        *)
            echo "⚠️ Please answer 'y' or 'n'."
            ;;
    esac
done

git init
git remote add origin git@github.com:Jelle-S/tilde.git
git pull origin master

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

sudo snap install dbeaver-ce
