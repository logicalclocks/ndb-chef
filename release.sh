#!/bin/bash

cb=ndb

rm -rf /tmp/cookbooks
berks vendor /tmp/cookbooks
cp metadata.rb /tmp/cookbooks/$cb/
knife cookbook site share $cb Applications
