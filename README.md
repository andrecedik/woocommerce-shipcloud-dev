## Deploy

You may want to open these during the process:

- https://shipcloud.slack.com
- https://github.com/awsmug/shipcloud-for-woocommerce
- https://plugins.svn.wordpress.org/shipcloud-for-woocommerce/tags/
- https://de.wordpress.org/plugins/shipcloud-for-woocommerce/

Hop in the correct dir:

    cd src/plugins/shipcloud-for-woocommerce/

Run:

    git checkout release/1.4
    git status # needs to be clean
    git fetch --all --prune --tags
    git pull origin release/1.4
    git merge origin/master # just to be sure we got everything

Now:

- Version bump on at least:
  - readme.md
  - readme.txt
  - \WooCommerce_Shipcloud::VERSION
  - woocommerce-shipcloud.php
  - `grep -r '1\.4\.0' *` has no other odd entry.
- Changelog at least (`git log --reverse 1.4.0..HEAD` helps):
  - readme.txt
  - changelog.txt

Then prepare:

    git add readme.md readme.txt changelog.txt woocommerce-shipcloud.php
    # and others
    git commit -m 'Version bump 1.4.0'
    

And deploy:

    git checkout master
    git merge release/1.4
    git status # should be empty
    git tag 1.4.2 -m "Released 1.4.2"
    # go back to base dir
    cd ..; cd $(git rev-parse --show-toplevel)
     ./deploy.sh username password    

Make github release:

    cd src/plugins/shipcloud-for-woocommerce/; \
    git push origin master; \
    git push --tags
    
    git checkout release/1.4 ;\
    git push origin release/1.4
    
Goto https://github.com/awsmug/shipcloud-for-woocommerce/releases/new
and create the new one by using "readme.txt" and "changelog.txt".

Cleanup:
    
    git branch -a --merged
    # remove those branches EXCEPT RELEASE BRANCHES OR MASTER
    git push origin :branchname

Now goto https://shipcloud.slack.com
and spread the news:

@here
- https://de.wordpress.org/plugins/shipcloud-for-woocommerce/
- https://plugins.svn.wordpress.org/shipcloud-for-woocommerce/tags/
- https://github.com/awsmug/shipcloud-for-woocommerce/releases
