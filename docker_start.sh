cd $HOME

# try to remove the repo if it already exists
rm -rf tn; true

git clone https://github.com/iconix/tn.git

cd tn

npm install --quiet && npm install --quiet -g coffee-script

# compile CoffeeScript
coffee --compile --output lib/ src/

npm run startprod
