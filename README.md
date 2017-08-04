## Deploy

Hop in the correct dir:

    cd src/plugins/shipcloud-for-woocommerce/

Run:

    git checkout master
    git status # needs to be clean
    git fetch --all --tags
    git merge origin/release/1.4

Now:

- Version bump on at least:
  - readme.md
  - readme.txt
  - \WooCommerce_Shipcloud::VERSION
  - woocommerce-shipcloud.php
  - `grep -r '1.4.0' *` has no other odd entry.
- Changelog at least (`git log 1.4.0..HEAD` helps):
  - readme
  - changelog.txt

Then prepare:

    git add readme.md readme.txt changelog.txt
    # and others
    git commit -m 'Version bump 1.4.0'
    

And deploy:

     ./deploy.sh username password    

Cleanup:
    
    git push origin master
    git push --tags
    
    git checkout release/1.4
    git merge master
    git push origin release/1.4
    
    git branch -a --merged
    # remove those branches EXCEPT RELEASE BRANCHES OR MASTER
    git push origin :branchname

