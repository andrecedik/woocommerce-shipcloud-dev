#!/bin/bash

set -e

exec 2>deploy.log
set -x


# main config
PLUGINSLUG="shipcloud-for-woocommerce"
CURRENTDIR=`pwd`
MAINFILE="woocommerce-shipcloud.php" # This should be the name of your main php file in the WordPress plugin
DEFAULT_EDITOR="/usr/bin/vi"

# git config
GITPATH="$CURRENTDIR/src/plugins/$PLUGINSLUG/" # this file should be in the base of your git repository
ASSETSFOLDER="assets"
ASSETSPATH="$GITPATH/$ASSETSFOLDER/" # this file should be in the base of your git repository

# svn config
SVNPATH="/tmp/$PLUGINSLUG" # Path to a temp SVN repo. No trailing slash required.
SVNURL="https://plugins.svn.wordpress.org/$PLUGINSLUG/" # Remote SVN repo on wordpress.org
SVNUSER=$1
SVNPASS=$2

if [ "$SVNUSER" == "" ] || [ "$SVNPASS" == "" ]
	then echo "Please enter a SVN username and password (e.g. deploy USERNAME PASSWORD)"
	exit 1
fi

[[ -d $SVNPATH ]] && rm -rf $SVNPATH

# Let's begin...
echo
echo "Deploy WordPress plugin"
echo "======================="
echo

# Check version in readme.txt is the same as plugin file after translating both to unix
# line breaks to work around grep's failure to identify mac line breaks
NEWVERSION1=`grep "^Stable tag:" "$GITPATH/readme.txt" | awk -F' ' '{print $NF}'`
echo "readme.txt version: $NEWVERSION1"
NEWVERSION2=`grep "Version: " "$GITPATH/$MAINFILE" | awk -F' ' '{print $NF}'`
echo "$MAINFILE version: $NEWVERSION2"

if [ "$NEWVERSION1" != "$NEWVERSION2" ]
	then echo "Version in readme.txt & $MAINFILE don't match. Exiting."
	exit 1
fi

echo "Versions match in readme.txt and $MAINFILE. Let's proceed..."

if git show-ref --quiet --tags --verify -- "refs/tags/$NEWVERSION1"
	then
		echo "Version $NEWVERSION1 already exists as git tag. Skipping."
	else
		printf "Tagging new Git version..."
		git tag -a "$NEWVERSION1" -m "tagged version $NEWVERSION1"
		echo "Done."

		printf "Pushing new Git tag..."
		git push --quiet --tags
		echo "Done."
fi

cd $GITPATH

printf "Creating local copy of SVN repo..."
svn checkout --quiet $SVNURL/trunk $SVNPATH/trunk
echo "Done."

printf "Exporting the HEAD of master from Git to the trunk of SVN..."
git checkout-index --quiet --all --force --prefix=$SVNPATH/trunk/
echo "Done."

printf "Preparing commit message..."
echo "updated version to $NEWVERSION1" > /tmp/wppdcommitmsg.tmp
echo "Done."

echo "Preparing assets-wp-repo..."
if [ -d $ASSETSPATH ]
	then
		svn checkout --quiet $SVNURL/assets $SVNPATH/assets > /dev/null
        [[ -d $SVNPATH/assets/ ]] || mkdir $SVNPATH/assets/ > /dev/null # Create assets directory if it doesn't exists
		cp -a $SVNPATH/trunk/$ASSETSFOLDER/* $SVNPATH/assets/ # Move new assets
		echo "  SVN: Remove asset folder..."
		rm -rf $SVNPATH/trunk/$ASSETSFOLDER # Clean up
		cd $SVNPATH/assets/ # Switch to assets directory
		if svn stat | grep "^?\|^M"
			then
				svn stat | grep "^?" | awk '{print $2}' | xargs svn add --quiet # Add new assets
				echo -en "Committing new assets..."
				svn commit --quiet -m "updated assets"
				echo "Done."
			else
				echo "Unchanged."
		fi
	else
		echo "No assets exists."
fi

cd $SVNPATH/trunk/

printf "Installing Composer dependencies..."
if [ -f composer.lock ]
	then rm composer.lock
fi

[[ -f composer.json ]] && composer install --prefer-dist --no-dev --quiet
echo "Done."

printf "Ignoring GitHub specific files and deployment script..."
svn propset --quiet svn:ignore ".bowerrc
.codeclimate.yml
.git
.gitignore
.travis.yml
bower.json
composer.json
composer.lock
CONTRIBUTING.md
deploy.sh
gulpfile.js
Gruntfile.js
package.json
phpunit.xml
README.md
tests" .
echo "Done."

if svn stat | grep "^?"; then
    printf "Adding new files..."
    svn stat | grep "^?" | awk '{print $2}' | xargs svn add --quiet
    echo "Done."
fi

if svn stat | grep "^\!"; then
    printf "Removing old files..."
    svn stat | grep "^\!" | awk '{print $2}' | xargs svn remove --quiet
    echo "Done."
fi

printf "Enter a commit message for this new SVN version..."
$DEFAULT_EDITOR /tmp/wppdcommitmsg.tmp
COMMITMSG=`cat /tmp/wppdcommitmsg.tmp`
rm /tmp/wppdcommitmsg.tmp
echo "Done."

printf "Committing new SVN version..."
svn commit --username "$SVNUSER" --password "$SVNPASS" --quiet -m "$COMMITMSG"
echo "Done."

printf "Tagging and committing new SVN tag..."
echo "Deleting: $SVNURL/tags/$NEWVERSION1"
if ! svn delete $SVNURL/tags/$NEWVERSION1 -m "Renewing Tag"; then
    echo "First time this version will be pushed."
fi

CP_FROM="$SVNURL/trunk"
CP_TO="$SVNURL/tags/$NEWVERSION1"

echo "Copy from: $CP_FROM"
echo "Copy to: $CP_TO"
svn cp $CP_FROM $CP_TO -m "tagged version $NEWVERSION1"

echo "Done."

printf "Removing temporary directory %s..." "$SVNPATH"
rm -rf $SVNPATH/
echo "Done."

echo
echo "Plugin $PLUGINSLUG version $NEWVERSION1 has been successfully deployed."
echo
