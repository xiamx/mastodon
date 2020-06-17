#!/bin/bash

git push
ssh mastodon@m.gretaoto.ca "source \$HOME/.profile && cd live && git pull && bundle && bundle exec rails assets:precompile && bundle exec rails db:migrate"
ssh root@m.gretaoto.ca "systemctl reload mastodon-web && systemctl restart mastodon-sidekiq && systemctl restart mastodon-streaming"

