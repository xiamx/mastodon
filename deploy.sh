#!/bin/bash

git push
ssh kimsufi 'echo "export RAILS_ENV=production && sleep 1 && source \$HOME/.bashrc && cd live && git fetch && git reset origin/master --hard && /home/mastodon/.rbenv/shims/bundle && /home/mastodon/.rbenv/shims/bundle exec rails assets:precompile && /home/mastodon/.rbenv/shims/bundle exec rails db:migrate" | lxc exec gretaoto-mastodon -- su --login mastodon'
ssh kimsufi 'lxc exec gretaoto-mastodon -- bash -c "systemctl reload mastodon-web && systemctl restart mastodon-sidekiq && systemctl restart mastodon-streaming"'

